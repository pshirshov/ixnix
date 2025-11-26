# ixnix

[![CI](https://github.com/pshirshov/ixnix/actions/workflows/ci.yml/badge.svg)](https://github.com/pshirshov/ixnix/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Nix flake that packages the [IX](https://github.com/stal-ix/ix) package manager and wraps it with the tools it expects (clang, llvm, binutils, curl, git, etc.). Works on Linux and macOS.

## Quick start

```
direnv allow .
nix build .#ix
./result/bin/ix --help
```

## Build LuaJIT via IX (standalone/local executor)

The upstream docs describe using IX standalone by setting `IX_ROOT` and `IX_EXEC_KIND=local`. For a LuaJIT smoke test:

```
export IX_ROOT=$PWD/.ix
export IX_EXEC_KIND=local
mkdir -p "$IX_ROOT/realm"

./result/bin/ix build lib/lua/jit --kind=bin               # requires the build toolchain in PATH
# If your PATH lacks clang/clang-cpp, run inside the dev shell (preferred):
# nix develop -c bash -lc './result/bin/ix build lib/lua/jit --kind=bin'

This leaves built artifacts under `$IX_ROOT`.

## Dev shell

```
nix develop
```

Provides ix plus clang/llvm/cmake/ninja/pkg-config and common fetch/build utilities.
