#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [build|test|switch|nvim]\n' "${0##*/}"
  printf 'Default action: switch. Set NIXOS_BASE_CONFIG to use a different existing NixOS module.\n'
}

case "${1:-switch}" in
  -h|--help) usage; exit 0 ;;
  build|test|switch|nvim) action=${1:-switch} ;;
  *) usage >&2; exit 2 ;;
esac
if (( $# > 1 )); then
  usage >&2
  exit 2
fi

setup_nvim() {
  if (( EUID == 0 )); then
    printf 'Run ./setup.sh nvim as your regular user to set up Neovim.\n' >&2
    return
  fi

  local nvim_config="$HOME/.config/nvim"
  if [[ "${XDG_CONFIG_HOME:-}" == /* ]]; then
    nvim_config="$XDG_CONFIG_HOME/nvim"
  fi

  if [[ -L "$nvim_config" || ( -e "$nvim_config" && ! -d "$nvim_config" ) ]]; then
    printf 'Using existing Neovim config at %s.\n' "$nvim_config"
    return
  fi
  if [[ -d "$nvim_config" ]]; then
    local existing_entry
    existing_entry=$(find "$nvim_config" -mindepth 1 -maxdepth 1 -print -quit)
    if [[ -n "$existing_entry" ]]; then
      printf 'Using existing Neovim config at %s.\n' "$nvim_config"
      return
    fi
  fi

  mkdir -p -- "$(dirname -- "$nvim_config")"
  git clone https://github.com/githubUser435543/nvim-config.git "$nvim_config"
}

if [[ "$action" == nvim ]]; then
  setup_nvim
  exit
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
sudo env NIXOS_BASE_CONFIG="$base_config" nixos-rebuild "$action" --impure --flake "$flake"

if [[ "$action" == switch ]]; then
  setup_nvim
fi
