## Layout

This is for plain (non-NixOS) Linux machines, managed with standalone
[home-manager](https://nix-community.github.io/home-manager/) rather than a
full system flake. Only the user environment is declarative here — OS
packages and services stay whatever the distro's own package manager thinks
they are.

```
.
├── home-manager.nix   # Defines user programs, built on modules/shared
├── packages.nix        # List of packages to install for the user
```

## Rebuilding debian-work-nix: steps home-manager doesn't cover

`nix run .#build-switch` restores the user environment only. After a fresh Debian install
(this box was rebuilt onto a new SSD in 2026-09), these steps also have to be done by hand:

1. **Nix + home-manager**: install Nix, clone this repo, `nix run .#build-switch`.
2. **1Password CLI sign-in**: `op account add`, then `eval $(op signin)`. The box is headless, so there is
   no 1Password desktop app and no 1Password SSH agent.
3. **Keys from 1Password**, written straight to disk:
   - SSH: `~/.ssh/id_ed25519` (item `id_ed25519`) and `~/.ssh/ha_config_ed25519` (secure note
     "Home Assistant config access (debian-work-nix)"). `chmod 600` both.
   - sops age key: `op read "op://Private/age-homelab/key" > ~/.config/sops/age/keys.txt` (`chmod 600`).
4. **Git commit signing** needs nothing extra. On Linux it uses `ssh-keygen` with `~/.ssh/id_ed25519`
   (see `modules/shared/home-manager.nix`) because `op-ssh-sign` needs the desktop app.
   Until step 3 is done, every commit fails.
5. **Tailscale** (system daemon, so apt instead of nix): add the `pkgs.tailscale.com` debian repo for the
   current codename, `apt install tailscale`, then `sudo tailscale up --ssh --hostname=debian-work-nix`
   and approve the login link.
6. **Omnigent host** (the box runs the homelab Omnigent server's agents):
   `uv tool install omnigent`, `omnigent login https://omnigent.lab.bray.pizza`
   (credentials are in 1Password), then `omnigent host enable`. That creates the `omnigent-host`
   systemd user service. Check that `loginctl show-user adam -p Linger` says `yes`, or the service
   stops on logout.
7. **Homelab tofu vars**: run `infrastructure/proxmox/terraform/render-tfvars.sh` in the homelab repo to
   write both `terraform.tfvars` files from 1Password.
