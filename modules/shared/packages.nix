{ pkgs }:

with pkgs; [
  # General packages for development and system management
#  alacritty
  bash-completion
  bat
  btop
  coreutils
  killall
  openssh
  sqlite
  wget
  zip

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2

  # Cloud-related tools and SDKs
#  docker
#  docker-compose

  # Media-related packages
  dejavu_fonts
#  ffmpeg
  fd
  font-awesome
  noto-fonts
  noto-fonts-color-emoji

  # Nerd Fonts - Fonts with icons for command line
  nerd-fonts.fira-code
  nerd-fonts.meslo-lg

  # Node.js development tools
#  nodejs_24

  # Text and terminal utilities
  neovim
  htop
  jq
  ripgrep
  tree
  tmux
  unrar
  unzip
  zsh-powerlevel10k
  obsidian

  # Development tools
  curl
  gh
#  terraform
#  kubectl
#  awscli2
  lazygit
  fzf
  direnv
  tree-sitter
  bottom
  lnav
  
  # Programming languages and runtimes
  go
#  rustc
#  cargo
  openjdk8
  nodejs_22

  # Python packages
  python3
  virtualenv

  maven
]
