# Older MacBook kept as an always-on home server (BlueBubbles + Reminders
# helper for family-agent). Mirrors the personal (midnight-air) config, plus
# the server-only settings below.
{ user, ... }:

let
  mainSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYPlWUM3LaYEP8hKUWCaixu6X+yNq96v1YIC9Diu+M2";
in
{
  imports = [ ../personal ];

  power = {
    sleep.computer = "never";
    sleep.display = 10;
    sleep.harddisk = "never";
    restartAfterFreeze = true;
  };

  networking.wakeOnLan.enable = true;

  # SSH in as either account with the main 1Password key (id_ed25519, Homelab
  # vault). Key-only; keys land in /etc/ssh/nix_authorized_keys.d/<user>.
  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    '';
  };
  users.users.${user}.openssh.authorizedKeys.keys = [ mainSshKey ];
  # Not created by nix-darwin (not in knownUsers); this only adds the key.
  users.users.familyagent.openssh.authorizedKeys.keys = [ mainSshKey ];

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
  # familyagent is a standard user, and macOS only lets admins SSH in by
  # default (the com.apple.access_ssh group), so add it explicitly.
  system.activationScripts.postActivation.text = ''
    pmset -a disablesleep 1
    dseditgroup -o edit -a familyagent -t user com.apple.access_ssh
  '';
}
