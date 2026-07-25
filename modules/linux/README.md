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
