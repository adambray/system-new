{ config, pkgs, ... }:

let user = "adambray"; in

{
  imports = [ ../darwin ];

  local.dock = {
    enable   = true;
    username = user;
    entries  = [
      { path = "/System/Applications/Stickies.app/"; }
      { path = "/Applications/Slack.app/"; }
      { path = "/Applications/Firefox.app/"; }
      { path = "/Applications/Google Chrome.app/"; }
      { path = "/Applications/iTerm.app/"; }
      { path = "/Applications/Notion.app/"; }
      { path = "/Applications/1Password.app/"; }
      { path = "/Applications/IntelliJ IDEA.app/"; }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort dateadded --view fan --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/Desktop/Screen Recordings";
        section = "others";
        options = "--sort dateadded --view fan --display folder";
      }
    ];
  };

  # TODO: move to a work-specific packages.nix if that gets created
  home-manager.users.${user}.home = {
    packages = [ pkgs.teleport_17 ];
    sessionVariables = {
      TELEPORT_PROXY = "teleport.platform.mechanical.run";
      TELEPORT_ADD_KEYS_TO_AGENT = "no";
    };
  };

  homebrew.brews = [
    "azure-cli"
    "git-duet/tap/git-duet"
    "pdm"
    "gnucobol"
  ];

  homebrew.casks = [
    "amazon-workspaces"
    "gcloud-cli"
    "hex-fiend"
    "tandem"
    "tuple"
  ];
}
