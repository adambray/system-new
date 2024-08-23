{ pkgs }:

with pkgs; [
  # General packages for development and system management
  aspell
  aspellDicts.en
  bash-completion
  bat
  btop
  # codespell
  coreutils
  killall
  kubectl
  k9s
  lazygit
  nixpkgs-fmt
  # neofetch
  # openssh
  # packer
  rustup
  terraform
  talosctl
  # sqlite
  watch
  wget
  # zip
  sqlcmd

  # Encryption and security tools
  # age
  # age-plugin-yubikey
  gnupg
  # libfido2

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  dejavu_fonts
  # ffmpeg
  fd
  # font-awesome
  # hack-font
  # noto-fonts
  # noto-fonts-emoji
  # meslo-lgs-nf
  (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })

  # Node.js development tools
  # nodePackages.npm # globally install npm
  # nodePackages.prettier
  # nodejs

  # Text and terminal utilities
  htop
  # hunspell
  # iftop
  jetbrains-mono
  jq
  ripgrep
  tree
  tmux
  # unrar
  # unzip
  zsh-powerlevel10k

]
