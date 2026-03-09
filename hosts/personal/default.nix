{ config, pkgs, ... }:

let user = "adambray"; in

{
  imports = [ ../darwin ];

  local.dock = {
    enable   = true;
    username = user;
    entries  = [
      { path = "/Applications/Firefox.app/"; }
      { path = "/Applications/Messages.app/"; }
      { path = "/Applications/Google Chrome.app/"; }
      { path = "/Applications/iTerm.app/"; }
      { path = "/Applications/Notion.app/"; }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort dateadded --view fan --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/Desktop/";
        section = "others";
        options = "--sort dateadded --view fan --display folder";
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    # Kubernetes / GitOps
    fluxcd
    talhelper
    kubernetes-helm
    helmfile
    kustomize
    stern
    kubectx
    velero

    # Secrets
    sops
    age

    # Storage / infra
    minio-client
  ];

  homebrew.casks = [
    "docker-desktop"
    "whatsapp"
    "gcloud-cli"
    "betterdisplay"
    "lulu"
    "plex"
    "the-unarchiver"
  ];
}
