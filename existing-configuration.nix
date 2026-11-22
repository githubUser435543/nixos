let
  configPath = builtins.getEnv "NIXOS_BASE_CONFIG";
in
{
  imports = [
    (if configPath == "" then
      throw "Run setup.sh to apply this profile to an existing NixOS configuration."
    else
      /. + configPath)
  ];
}
