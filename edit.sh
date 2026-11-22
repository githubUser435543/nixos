#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s {configuration.nix|packages.nix}\n' "${0##*/}"
}

if (( $# != 1 )); then
  usage >&2
  exit 2
fi

case "$1" in
  -h|--help) usage; exit 0 ;;
  configuration|configuration.nix) file=configuration.nix ;;
  packages|packages.nix) file=packages.nix ;;
  *) usage >&2; exit 2 ;;
esac

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
git ls-files --error-unmatch -- "$file" >/dev/null
if ! command -v nvim >/dev/null; then
  printf 'Neovim (nvim) is required. Apply the Framework profile first with ./setup.sh.\n' >&2
  exit 1
fi
nvim -- "$file"

changed=$(git diff --name-only HEAD -- "$file")
if [[ -z "$changed" ]]; then
  printf 'No changes to %s.\n' "$file"
  exit 0
fi

edited_hash=$(git hash-object --no-filters -- "$file")
if ! ./setup.sh switch; then
  printf 'NixOS switch failed. Your edits are still in %s.\n' "$file" >&2
  exit 1
fi

if [[ "$(git hash-object --no-filters -- "$file")" != "$edited_hash" ]]; then
  printf '%s changed during the rebuild. Run the script again to rebuild and commit.\n' "$file" >&2
  exit 1
fi
git commit --only -m "Update $file" -- "$file"
