{ lib, pkgs, ... }:

{
  imports = [ ./packages.nix ];

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  networking.hostName = "framework12";
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openconnect pkgs.networkmanager-openvpn ];
  };
  networking.firewall.enable = true;

  hardware.bluetooth.enable = true;
  hardware.graphics.extraPackages = [
    pkgs.intel-compute-runtime
    pkgs.intel-media-driver
  ];
  services.fwupd.enable = true;

  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  programs.sway.enable = true;

  fonts.packages = [ pkgs.dejavu_fonts ];
  services.flatpak.enable = true;
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    daemon.settings.runtimes.runsc.path = lib.getExe' pkgs.gvisor "runsc";
  };
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Set this to your preferred login before installing.
  users.users.laptop = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Initial NixOS release for this machine. Keep this across upgrades.
  system.stateVersion = "26.05";
}
