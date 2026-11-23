{ config, lib, pkgs, ... }:

let
  gtkSettings = ''
    [Settings]
    gtk-theme-name=Gruvbox-Dark
    gtk-application-prefer-dark-theme=true
  '';
in
{
  imports = [
    ./packages.nix
    ./chromium-extensions.nix
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
      --replace-fail 'set $mod Mod4' 'set $mod Mod1'
    echo 'seat * xcursor_theme Adwaita 24' >> "$out"
  '';

  programs.foot = {
    enable = true;
    settings = {
      main.font = "monospace:size=16";
      bell = {
        system = false;
        urgent = false;
        notify = false;
        visual = false;
      };
    };
  };

  environment.systemPackages = [
    (pkgs.gruvbox-gtk-theme.override { colorVariants = [ "dark" ]; })
    pkgs.gruvbox-kvantum
  ];
  environment.pathsToLink = [ "/share/Kvantum" ];
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
}
