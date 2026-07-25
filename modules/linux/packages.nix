{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  # Lets `home-manager` itself be run without a separate install step
  home-manager
]
