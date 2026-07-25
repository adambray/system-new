{ config, pkgs, lib, ... }:

let
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
  shared-files = import ../shared/files.nix { inherit config pkgs; };
in
{
  # This machine isn't running NixOS, so tell home-manager to patch things
  # like dynamic linker paths that NixOS would otherwise handle for us.
  targets.genericLinux.enable = true;

  home.file = shared-files;

  programs = shared-programs;

  fonts.fontconfig.enable = true;
}
