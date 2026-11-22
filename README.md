# Framework Laptop 12

NixOS 26.05 for the x86_64 Framework Laptop 12 with 13th-generation Intel
graphics and firmware support. The configuration uses Sway, PipeWire, Bluetooth,
NetworkManager, and the NixOS firewall. TLP is enabled by default when the
existing system does not use Power Profiles Daemon.

## Apply on an existing NixOS installation

On the Framework, clone the private repo with your GitHub credentials and run
the setup script. This example assumes your GitHub SSH key is configured.

```sh
git clone git@github.com:githubUser435543/nixos.git
cd nixos
./setup.sh
```

If Git is missing, run `nix-shell -p git` before cloning.

The script imports `/etc/nixos/configuration.nix` and adds the Framework
profile and packages. It uses your existing disk mounts, bootloader, login,
hostname, and `system.stateVersion`. If your current install uses a different
configuration module, pass its path with
`NIXOS_BASE_CONFIG=/path/to/configuration.nix ./setup.sh`. If your existing
flake supplies extra inputs or module arguments, integrate the profile modules
into that flake so those inputs stay available.

By default, the script builds and activates the configuration and selects it
for future boots. Run `./setup.sh build` to build without activating, or
`./setup.sh test` to activate for the current boot before switching. To apply
future repo changes, pull them and run the script again. If you need to return
to the previous system generation after switching, run
`sudo nixos-rebuild switch --rollback`.

The script keeps your current desktop configuration. Choose Sway at the login
screen if your display manager lists it, or log in on a text console and run
`sway`. If you bring over a custom Sway config, include `/etc/sway/config.d/*`
for screen sharing and session integration.

## Edit, rebuild, and commit

```sh
./edit.sh configuration.nix
./edit.sh packages.nix
```

Each command opens the selected file in Neovim. When you save and exit, the
script runs `./setup.sh switch` if the file differs from the last commit. A
successful switch creates a local commit for that file only. If the switch
fails, your edits stay in the working tree so you can fix them and retry.
The rebuild uses the current checkout, including any other local changes.

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
