{ config, pkgs, ... }:

let user = "adam"; in

{
  imports = [ ../../../modules/linux/home-manager.nix ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ../../../modules/linux/packages.nix {};
    stateVersion = "24.11";
  };
}
