# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Nix flake-based configuration for macOS (nix-darwin) machines and plain (non-NixOS) Linux machines. macOS gets full system management (packages, dotfiles, homebrew casks, dock) via nix-darwin; Linux machines get user-environment management only (dotfiles, CLI packages, shell) via standalone home-manager, since the OS itself isn't NixOS.

## Key Commands

**Build without switching (macOS):**
```sh
nix run .#build
```

**Build and switch to new generation (macOS or Linux):**
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
nix build .#homeConfigurations.<hostname>.activationPackage
```

## Architecture

```
flake.nix              # Entry point; defines inputs and wires together all configurations
hosts/
  darwin/default.nix   # macOS system-level config (dock, keyboard, trackpad, nix settings)
  personal/, work/     # Per-machine darwinConfigurations, import hosts/darwin
  linux/               # Per-machine homeConfigurations (standalone home-manager, non-NixOS)
modules/
  darwin/              # macOS-only modules (home-manager, packages, files, dock config)
  linux/               # Non-NixOS Linux modules (home-manager, packages) — see modules/linux/README.md
  shared/              # Cross-platform config imported by both darwin and linux
    default.nix        # Applies all overlays from /overlays (nix-darwin module form)
    home-manager.nix   # Most user-level config: git, zsh, vim, tmux, etc.
    packages.nix       # Shared package list
    files.nix          # Static dotfiles deployed to home directory
    cachix/            # Binary cache configuration
overlays/              # Nix overlays — auto-loaded by modules/shared/default.nix (darwin) and inlined in flake.nix (linux)
apps/                  # Shell scripts exposed as flake apps per platform
```

## How Configuration Flows

**macOS**: `flake.nix` creates `darwinConfigurations` via `darwin.lib.darwinSystem`. Each host imports `hosts/darwin/default.nix`, which imports `modules/darwin/home-manager.nix`, which pulls in `modules/shared/home-manager.nix` for cross-platform program config.

**Linux (non-NixOS)**: `flake.nix` creates `homeConfigurations`, keyed by hostname, via `home-manager.lib.homeManagerConfiguration` (standalone, no NixOS module system involved). Each host is a directory under `hosts/linux/` that imports `modules/linux/home-manager.nix`, which pulls in `modules/shared/home-manager.nix` the same way the darwin side does. `targets.genericLinux.enable` is set so home-manager patches things (dynamic linker paths, etc.) that NixOS would otherwise handle.

`modules/shared/home-manager.nix` is the primary place for user-level tool configuration shared across both platforms.

## Platform Tokens

The `apply` script is used for first-time setup to replace `%USER%`, `%EMAIL%`, `%NAME%` placeholders in Nix files before building.

## Adding Things

- **Shared packages**: `modules/shared/packages.nix`
- **macOS-only packages**: `modules/darwin/packages.nix`
- **Linux-only packages**: `modules/linux/packages.nix`
- **Homebrew casks** (macOS): `modules/darwin/casks.nix`
- **User program config** (shared): `modules/shared/home-manager.nix`
- **Static dotfiles**: `modules/shared/files.nix` or `modules/darwin/files.nix`
- **New Linux machine**: add a `hosts/linux/<name>/default.nix` (see `hosts/linux/work/default.nix`) and register it in `flake.nix`'s `homeConfigurations`
- **Patches/version overrides**: add a `.nix` file to `overlays/`
