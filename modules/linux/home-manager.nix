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

  programs = lib.recursiveUpdate shared-programs {
    # Claude Code sessions get the homelab 1Password service account (Homelab
    # vault only). .zshenv, because Claude's shells are non-interactive. Gated
    # on CLAUDECODE so `op` in your own shells keeps the personal account.
    zsh.envExtra = ''
      if [[ -n "$CLAUDECODE" && -r ~/.config/op/homelab-sa-token ]]; then
        export OP_SERVICE_ACCOUNT_TOKEN="$(<~/.config/op/homelab-sa-token)"
      fi
    '';
  };

  fonts.fontconfig.enable = true;
}
