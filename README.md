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

The script builds `framework12`. It imports `/etc/nixos/configuration.nix`,
including its hardware module, to reuse your bootloader, disk mounts, swap,
and existing `system.stateVersion`. The profile sets the hostname to
`BarakObama` and declares the `ethan` account in `flake.nix`.
If your installation uses a different configuration module, pass its path with
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
for screen sharing and session integration. The system Sway config uses Alt
(`Mod1`) and the Adwaita cursor. The bar shows workspaces and status information
with the system tray hidden. Press Shift+Alt+S to select a rectangle and save it
under `~/Pictures/Screenshots` (or `$XDG_PICTURES_DIR/Screenshots` if set).
A personal Sway config takes precedence.

The desktop advertises a dark-mode preference to applications. Foot starts in
Gruvbox Dark with a 16-point monospace font and the bell disabled. Ranger uses
Foot's colors. GTK uses Gruvbox Dark, and Qt uses Gruvbox Dark Brown through
Kvantum. Personal app and toolkit settings can take precedence.

Ungoogled Chromium starts in dark mode and loads Chromium Web Store,
uBlock Origin Lite, Wappalyzer, FoxyProxy Standard, and Bitwarden from
the system profile. After rebuilding, fully quit and reopen the browser
and check `chrome://extensions` for any enable prompts. The bundled
versions and hashes are declared in `chromium-extensions.nix`.

## Neovim configuration

Run `./setup.sh` as your regular user. After a successful switch, it clones
[your Neovim config](https://github.com/githubUser435543/nvim-config) into
`~/.config/nvim` (or `$XDG_CONFIG_HOME/nvim`). Neovim loads the checkout
automatically. Run `./setup.sh nvim` to install it without a system rebuild.
Setup fills an empty config directory and preserves existing files and symlinks.
Make changes and pull updates in the Neovim checkout.

## SSH key

When the `ethan` user session starts, NixOS creates an Ed25519 key without a
passphrase in `~/.ssh/id_ed25519` if there is no existing SSH identity in `~/.ssh`.
After applying the configuration, run
`systemctl --user start generate-ssh-key.service` to check immediately. Add
`~/.ssh/id_ed25519.pub` to GitHub if you want to use the generated key there.

## Edit, rebuild, and commit

```sh
./edit.sh configuration.nix
./edit.sh packages.nix
./edit.sh hosts.nix
```

Each command opens the selected file in Neovim. When you save and exit, the
script runs `./setup.sh switch` if the file differs from the last commit. A
successful switch creates a local commit for that file only. Run `git push`
to publish it. If the switch fails, your edits stay in the working tree so you
can fix them and retry.
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
