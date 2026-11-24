{ config, lib, pkgs, ... }:

let
  gtkTheme = "Gruvbox-Dark";
  gtkSettings = ''
    [Settings]
    gtk-theme-name=${gtkTheme}
    gtk-application-prefer-dark-theme=true
  '';
in
{
  imports = [
    ./packages.nix
    ./hosts.nix
    ./chromium-extensions.nix
    ./i3status.nix
  ];

  networking.networkmanager = {
    enable = lib.mkDefault true;
    plugins = [ pkgs.networkmanager-openconnect pkgs.networkmanager-openvpn ];
  };
  networking.firewall.enable = lib.mkDefault true;

  hardware.bluetooth.enable = lib.mkDefault true;
  hardware.graphics.extraPackages = [
    pkgs.intel-compute-runtime
    pkgs.intel-media-driver
  ];

  services.tlp.enable = lib.mkDefault (!config.services.power-profiles-daemon.enable);

  security.rtkit.enable = lib.mkDefault true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault (!config.services.pulseaudio.enable);
    pulse.enable = lib.mkDefault (!config.services.pulseaudio.enable);
    wireplumber.enable = lib.mkDefault true;
  };

  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      export XCURSOR_THEME=Adwaita
      export XCURSOR_SIZE=24
      export XCURSOR_PATH="${pkgs.adwaita-icon-theme}/share/icons''${XCURSOR_PATH:+:$XCURSOR_PATH}"
    '';
  };
  environment.etc."sway/config".source = pkgs.runCommand "framework-sway-config" { } ''
    substitute ${config.programs.sway.package}/etc/sway/config "$out" \
      --replace-fail 'set $mod Mod4' 'set $mod Mod1' \
      --replace-fail "status_command while date +'%Y-%m-%d %X'; do sleep 1; done" \
        'status_command ${lib.getExe pkgs.i3status} -c /etc/i3status.conf'
    echo 'seat * xcursor_theme Adwaita 24' >> "$out"
  '';

  environment.etc."sway/config.d/50-touchpad.conf".text = ''
    input type:touchpad tap enabled
  '';

  programs.chromium = {
    enable = true;
    extraOpts.BookmarkBarEnabled = true;
  };

  programs.git = {
    enable = true;
    config.user = {
      name = "Jacob Wesson";
      email = "jacobwesson@proton.me";
    };
  };

  services.netbird.enable = true;

  systemd.user.services.generate-ssh-key = {
    description = "Generate an Ed25519 SSH key when no user key exists";
    wantedBy = [ "default.target" ];
    unitConfig.ConditionUser = "ethan";
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ coreutils openssh util-linux ];

    script = ''
      umask 077
      ssh_dir="$HOME/.ssh"
      key_path="$ssh_dir/id_ed25519"
      mkdir -p -- "$ssh_dir"

      exec 9<"$ssh_dir"
      flock 9

      if [[ -e "$key_path" || -L "$key_path" || -e "$key_path.pub" || -L "$key_path.pub" ]]; then
        exit 0
      fi

      shopt -s nullglob dotglob globstar
      for candidate in "$ssh_dir"/**/*; do
        case "''${candidate##*/}" in
          authorized_keys*|known_hosts*) continue ;;
        esac
        [[ -f "$candidate" && -r "$candidate" ]] || continue

        if ssh-keygen -lf "$candidate" </dev/null >/dev/null 2>&1; then
          exit 0
        fi

        # Encrypted legacy PEM keys may have no readable public counterpart.
        IFS= read -r header < "$candidate" || continue
        case "$header" in
          '-----BEGIN '*PRIVATE' KEY-----') exit 0 ;;
        esac
      done

      ssh-keygen -q -t ed25519 -N "" -C "jacobwesson@proton.me" -f "$key_path" </dev/null
    '';
  };

  programs.foot = {
    enable = true;
    theme = "gruvbox";
    settings = {
      main = {
        font = "monospace:size=16";
        initial-color-theme = "dark";
      };
      bell = {
        system = false;
        urgent = false;
        notify = false;
        visual = false;
      };
    };
  };

  environment.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

  xdg.mime = {
    enable = true;
    defaultApplications."inode/directory" = [ "ranger-foot.desktop" ];
  };

  systemd.user.services.ranger-directory-default = {
    description = "Set Ranger as the default directory handler";
    wantedBy = [ "sway-session.target" ];
    unitConfig.ConditionUser = "ethan";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.coreutils pkgs.xdg-utils ];
    script = ''
      if [ "$(xdg-mime query default inode/directory)" != ranger-foot.desktop ]; then
        mkdir -p -- "''${XDG_CONFIG_HOME:-$HOME/.config}"
        xdg-mime default ranger-foot.desktop inode/directory
      fi
    '';
  };

  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "ranger-foot";
      desktopName = "Ranger";
      exec = "${lib.getExe config.programs.foot.package} -- ${lib.getExe pkgs.ranger} %f";
      mimeTypes = [ "inode/directory" ];
    })
    (pkgs.gruvbox-gtk-theme.override { colorVariants = [ "dark" ]; })
    pkgs.gruvbox-kvantum
  ];
  environment.pathsToLink = [ "/share/Kvantum" ];
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = gtkTheme;
        };
      }
    ];
  };
  environment.sessionVariables.GTK_THEME = lib.mkDefault gtkTheme;
  environment.etc."xdg/gtk-3.0/settings.ini".text = gtkSettings;
  environment.etc."xdg/gtk-4.0/settings.ini".text = gtkSettings;
  environment.etc."xdg/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=Gruvbox-Dark-Brown
  '';
  qt = {
    enable = true;
    style = "kvantum";
  };

  fonts.packages = [ pkgs.dejavu_fonts ];
  services.flatpak.enable = true;
  virtualisation.docker = {
    enable = true;
    enableOnBoot = lib.mkDefault false;
    daemon.settings.runtimes.runsc.path = lib.getExe' pkgs.gvisor "runsc";
  };
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  environment.ldso32 = "${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2";
  programs.nix-ld.enable = true;
}
