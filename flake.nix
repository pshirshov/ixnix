{
  description = "Nix flake for the ix package manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
      ];

      ixRev = "1ac8f3629c1187104af166792dbe0420489f56b3";
      ixSha256 = "1jlmi34vvkvsvga5z5bc9m688n9a5zcamvbgywixaqy822f69x13";
      ixVersion = "unstable-2025-11-25";
    in
      flake-utils.lib.eachSystem systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          python = pkgs.python3;

          runtimeTools = with pkgs; [
            bash
            coreutils
            findutils
            gnused
            gnugrep
            gawk
            gnutar
            gzip
            bzip2
            xz
            zstd
            unzip
            curl
            wget
            git
            rsync
            patch
            diffutils
            openssl
            lld
          ];

          buildTools = with pkgs; [
            clang
            lld
            llvm
            gnumake
            cmake
            ninja
            pkg-config
          ];

          ixSource = pkgs.fetchFromGitHub {
            owner = "stal-ix";
            repo = "ix";
            rev = ixRev;
            sha256 = ixSha256;
          };

          ix = pkgs.stdenv.mkDerivation {
            pname = "ix";
            version = ixVersion;
            src = ixSource;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            dontBuild = true;
            strictDeps = true;

            installPhase = ''
              runHook preInstall

              mkdir -p $out/libexec/ix
              cp -r . $out/libexec/ix
              chmod +x $out/libexec/ix/ix

              # Provide an lld.ld alias expected by ix bootstrap logic.
              cat > $out/libexec/ix/lld.ld <<'EOF'
#!/usr/bin/env bash
exec ${pkgs.lld}/bin/ld.lld "$@"
EOF
              chmod +x $out/libexec/ix/lld.ld

              mkdir -p $out/bin
            makeWrapper ${python}/bin/python3 $out/bin/ix \
                --add-flags "$out/libexec/ix/ix" \
                --prefix PATH : ${pkgs.lib.makeBinPath (runtimeTools ++ buildTools)} \
                --prefix PATH : $out/libexec/ix

              install -Dm644 ix.1 $out/share/man/man1/ix.1

              runHook postInstall
            '';

            doInstallCheck = true;
            installCheckPhase = ''
              PYTHONPATH="$out/libexec/ix:${python}/${python.sitePackages}" \
                ${python}/bin/python - <<'PY'
import importlib
import sys

sys.path.insert(0, "$out/libexec/ix")
importlib.import_module("core.main")
importlib.import_module("core.entry")
PY
            '';

            meta = {
              description = "Statically focused package manager";
              homepage = "https://github.com/stal-ix/ix";
              license = pkgs.lib.licenses.mit;
              mainProgram = "ix";
              platforms = systems;
            };
          };
        in {
          packages = {
            inherit ix;
            default = ix;
          };

          apps.default = flake-utils.lib.mkApp { drv = ix; };

          devShells.default = pkgs.mkShell {
            packages = runtimeTools
              ++ buildTools
              ++ [
                python
                pkgs.nix
                ix
              ];
          };
        });
}
