{ config, pkgs, lib, home-manager, ... }:

let
  user = "adambray";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    
    casks = pkgs.callPackage ./casks.nix {};
    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [
      "node"
      "gettext"
      "nmap"
      "azure-cli"
      "gh"
      "git-duet/tap/git-duet"
      "pdm"
    ];
    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "wireguard" = 1451685025;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        sessionVariables = {
          SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
        };

        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
          { ".1password/agent.sock" = {
            source = config.lib.file.mkOutOfStoreSymlink
              "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          }; }
        ];
        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  # Fully declarative dock using the latest from Nix Store
 local.dock = {
    enable   = true;
    username = user;
    entries  = [
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/Firefox.app/"; }
    { path = "/System/Applications/Messages.app/"; }
    { path = "/System/Applications/Music.app/"; }
    { path = "/System/Applications/Photos.app/"; }
    { path = "/System/Applications/TV.app/"; }
    { path = "/System/Applications/Home.app/"; }
    {
      path = "${config.users.users.${user}.home}/Downloads";
      section = "others";
      options = "--sort dateadded --view fan --display folder";
      }
    ];
  };
}