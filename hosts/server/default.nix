{ user, ... }:

# Older MacBook kept as an always-on home server (BlueBubbles + Reminders
# helper for family-agent). Mirrors the personal (midnight-air) config, plus
# the server-only settings below.
{
  imports = [ ../personal ];

  power = {
    sleep.computer = "never";
    sleep.display = 10;
    sleep.harddisk = "never";
    restartAfterFreeze = true;
  };

  networking.wakeOnLan.enable = true;

  # The git signing / GitHub key lives in the Homelab vault, which the
  # 1Password SSH agent doesn't offer by default (only Personal/Private).
  # force: 1Password writes its own default file when the agent is enabled.
  home-manager.users.${user}.xdg.configFile."1Password/ssh/agent.toml" = {
    force = true;
    text = ''
      [[ssh-keys]]
      account = "my.1password.com"
      vault = "Private"

      [[ssh-keys]]
      account = "my.1password.com"
      vault = "Homelab"
    '';
  };

  # Keep running with the lid closed / no display attached; there's no
  # nix-darwin option for this one.
  system.activationScripts.postActivation.text = ''
    pmset -a disablesleep 1
  '';
}
