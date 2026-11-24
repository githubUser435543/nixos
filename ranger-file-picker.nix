{ config, lib, pkgs, ... }:

let
  portal = pkgs.xdg-desktop-portal-termfilechooser.overrideAttrs (old: {
    mesonFlags = old.mesonFlags ++ [ "--sysconfdir=/etc" ];
  });

  chooseWithRanger = pkgs.writeShellScript "ranger-file-picker" ''
    multiple="$1"
    directory="$2"
    save="$3"
    path="$4"
    result="$5"

    if [ "$save" = 1 ]; then
      set -- "--choosefile=$result" "--selectfile=$path"
    elif [ "$directory" = 1 ]; then
      set -- "--choosedir=$result" --show-only-dirs -- "$path"
    elif [ "$multiple" = 1 ]; then
      set -- "--choosefiles=$result" -- "$path"
    else
      set -- "--choosefile=$result" -- "$path"
    fi

    exec ${lib.getExe config.programs.foot.package} --title="Choose files" -- ${lib.getExe pkgs.ranger} "$@"
  '';
in
{
  xdg.portal.extraPortals = [ portal ];
  xdg.portal.config.sway."org.freedesktop.impl.portal.FileChooser" = [
    "termfilechooser"
    "gtk"
  ];

  environment.etc."xdg/xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${chooseWithRanger}
  '';
}
