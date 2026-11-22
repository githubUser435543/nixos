#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [build|test|switch]\n' "${0##*/}"
  printf 'Default action: switch. Set NIXOS_BASE_CONFIG to use a different existing NixOS module.\n'
}

case "${1:-switch}" in
  -h|--help) usage; exit 0 ;;
  build|test|switch) action=${1:-switch} ;;
  *) usage >&2; exit 2 ;;
esac
if (( $# > 1 )); then
  usage >&2
  exit 2
fi

if ! command -v nixos-rebuild >/dev/null || [[ "$(uname -m)" != x86_64 ]]; then
  printf 'Run this on the x86_64 Framework Laptop 12 with NixOS installed.\n' >&2
  exit 1
fi

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
base_config=$(realpath -m -- "${NIXOS_BASE_CONFIG:-/etc/nixos/configuration.nix}")
if [[ ! -f "$base_config" ]]; then
  printf 'Existing NixOS configuration not found at %s. Set NIXOS_BASE_CONFIG to its path.\n' "$base_config" >&2
  exit 1
fi

flake="path:$repo_dir#framework12-existing"
if [[ "$action" == build ]]; then
  exec env NIXOS_BASE_CONFIG="$base_config" nixos-rebuild build --impure --flake "$flake"
fi
exec sudo env NIXOS_BASE_CONFIG="$base_config" nixos-rebuild "$action" --impure --flake "$flake"
