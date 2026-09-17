{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  # Lets `home-manager` itself be run without a separate install step
  home-manager

  # 1Password CLI only (no GUI/desktop app — this box is headless).
  # Used for `op` vault access (e.g. homelab age/sops keys); SSH keys
  # are copied to disk directly instead of using 1Password's SSH agent,
  # since that feature requires the desktop app.
  _1password-cli

  # uv — used to install/run the `omnigent` CLI (github.com/omnigent-ai/omnigent),
  # which isn't packaged in nixpkgs yet. This box runs `omnigent host` to
  # register as an agent execution host for the Omnigent server in the
  # homelab k8s cluster.
  uv

  # 3D printing slicer (unfree; allowUnfree is set in flake.nix for
  # homeConfigurations)
  # bambu-studio  # TEMP disabled 2026-09-10: source build fails in this nixpkgs rev, no cached binary. Re-add when fixed, or use flatpak/AppImage.
]
