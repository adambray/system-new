{ config, ... }:

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

  homebrew.brews = [
    "azure-cli"
    "git-duet/tap/git-duet"
    "pdm"
    "gnucobol"
  ];

  homebrew.casks = [
    "amazon-workspaces"
    "hex-fiend"
    "tandem"
    "tuple"
  ];
}
