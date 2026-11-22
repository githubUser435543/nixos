{ config, lib, pkgs, ... }:

{
  imports = [ ./packages.nix ];

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

  programs.sway.enable = true;

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
