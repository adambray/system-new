# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Nix flake-based system configuration for macOS (nix-darwin) and NixOS machines. It manages system packages, dotfiles, homebrew casks, and home-manager user configuration declaratively.

## Key Commands

**Build without switching (macOS):**
```sh
nix run .#build
```

**Build and switch to new generation (macOS):**
```sh
nix run .#build-switch
```

**Apply user tokens (first-time setup):**
```sh
nix run .#apply
```

**Rollback to a previous generation (macOS):**
```sh
nix run .#rollback
```

All app scripts are in `apps/<system>/` (e.g., `apps/aarch64-darwin/`, `apps/x86_64-linux/`). The flake exposes them via `nix run .#<script-name>`.

To build manually with nix directly:
```sh
NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.aarch64-darwin.system
```

## Architecture

```
flake.nix              # Entry point; defines inputs and wires together all configurations
hosts/
  darwin/default.nix   # macOS system-level config (dock, keyboard, trackpad, nix settings)
  nixos/default.nix    # NixOS system-level config (boot, networking, services, users)
modules/
  darwin/              # macOS-only modules (home-manager, packages, files, dock config)
  nixos/               # NixOS-only modules (home-manager, packages, files, disk, rofi/polybar configs)
  shared/              # Cross-platform config imported by both darwin and nixos
    default.nix        # Applies all overlays from /overlays
    home-manager.nix   # Most user-level config: git, zsh, vim, tmux, etc.
    packages.nix       # Shared package list
    files.nix          # Static dotfiles deployed to home directory
    cachix/            # Binary cache configuration
overlays/              # Nix overlays — auto-loaded by modules/shared/default.nix
apps/                  # Shell scripts exposed as flake apps per platform
```

## How Configuration Flows

1. `flake.nix` creates `darwinConfigurations` and `nixosConfigurations` using `darwin.lib.darwinSystem` / `nixpkgs.lib.nixosSystem`
2. Each host imports its platform-specific `hosts/<platform>/default.nix`
3. Host configs import `modules/shared` (shared packages/overlays) and `modules/<platform>/home-manager.nix`
4. `modules/shared/home-manager.nix` is the primary place for user-level tool configuration
5. Overlays in `/overlays/` are automatically picked up by `modules/shared/default.nix`

## Platform Tokens

The `apply` script is used for first-time setup to replace `%USER%`, `%EMAIL%`, `%NAME%` (and on NixOS: `%INTERFACE%`, `%DISK%`, `%HOST%`) placeholders in Nix files before building.

## Adding Things

- **Shared packages**: `modules/shared/packages.nix`
- **macOS-only packages**: `modules/darwin/packages.nix`
- **NixOS-only packages**: `modules/nixos/packages.nix`
- **Homebrew casks** (macOS): `modules/darwin/casks.nix`
- **User program config** (shared): `modules/shared/home-manager.nix`
- **Static dotfiles**: `modules/shared/files.nix`, `modules/darwin/files.nix`, or `modules/nixos/files.nix`
- **Patches/version overrides**: add a `.nix` file to `overlays/`
