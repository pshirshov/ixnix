#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IX_ROOT="${IX_ROOT:-${root_dir}/.ix}"
IX_EXEC_KIND="${IX_EXEC_KIND:-local}"

export IX_ROOT
export IX_EXEC_KIND

mkdir -p "${IX_ROOT}/realm"

if [ ! -x "${root_dir}/result/bin/ix" ]; then
  echo "result/bin/ix is missing; build it first with: nix build .#ix" >&2
  exit 1
fi

echo "Using IX_ROOT=${IX_ROOT}"
echo "Building LuaJIT..."
"${root_dir}/result/bin/ix" build lib/lua/jit --kind=bin
