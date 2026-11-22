# Framework Laptop 12

NixOS 26.05 for the x86_64 Framework Laptop 12 with 13th-generation Intel
graphics and firmware support. The configuration uses Sway, PipeWire, Bluetooth,
NetworkManager, TLP, and the NixOS firewall. The desktop starts with Sway's
default settings.

## Install

1. Boot a NixOS installer in UEFI mode. Prepare and mount the intended NixOS
   filesystems under `/mnt` and mount the EFI system partition at `/mnt/boot`.
   If your EFI partition is mounted elsewhere, set
   `boot.loader.efi.efiSysMountPoint` accordingly.
2. Clone or copy this private repository onto the installer machine. From its
   checkout, copy in the hardware configuration generated for the target laptop:

   ```sh
   sudo nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix .
   ```

   The hardware file is ignored by Git. Keep a copy with the checkout you use
   for future rebuilds. For encrypted storage, verify the generated LUKS
   mappings and mounts before installation.
3. Set your login in `configuration.nix` if you want a name other than
   `laptop`. Set the timezone or keyboard layout there if you need to change
   the NixOS defaults. Install from the checkout:

   ```sh
   sudo nixos-install --flake "path:$PWD#framework12"
   ```

4. After rebooting, log in as root with the password set by the installer and
   run `passwd laptop` (or use your chosen login name). Log in as your regular
   user on the console and run `sway`. If you bring over a custom Sway config,
   include `/etc/sway/config.d/*` so screen sharing and session integration work.

For a machine already running NixOS, copy its hardware configuration and
preserve its existing `system.stateVersion`, bootloader, and user settings.
From the checkout, run `sudo nixos-rebuild test --flake "path:$PWD#framework12"`
before running the same command with `switch`. The explicit `path:` includes
the local hardware file when Nix reads the flake.

## Arch package migration

- `packages.nix` declares the apps and command-line tools. The system modules
  handle the kernel and firmware, desktop and audio integration, firewall,
  network management, and Docker. Flatpak is enabled. The inventory did not
  list any Flatpak apps or app settings.
- Crosspipe replaces Helvum, which was removed from this Nixpkgs release.
  OpenCode uses the packaged release. Node.js includes npm, and Zathura includes
  the MuPDF backend.
- `yay` and `yay-debug` are Arch-specific. This profile omits `rkhunter`,
  which has no package in the pinned Nixpkgs and needs NixOS-specific
  filesystem and baseline configuration.

Use `sudo docker` for Docker. To let your regular user capture live traffic in
Wireshark, add `"wireshark"` to that user's `extraGroups`.
