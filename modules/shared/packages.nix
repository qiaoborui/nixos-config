{ pkgs }:

with pkgs; [
  # Core system tools
#  alacritty
  bash-completion
  coreutils
  killall
  openssh
  sqlite
  wget
  zip

  # CLI utilities
  bat
  btop
  bottom
  fd
  fzf
  htop
  jq
  lnav
  ripgrep
  tree
  tmux
  tmuxp
  unrar
  unzip

  # Editors and terminal UI
  neovim
  zsh-powerlevel10k

  # Productivity
  obsidian

  # Security and encryption tools
  age
  age-plugin-yubikey
  gnupg
  libfido2

  # Fonts
  dejavu_fonts
#  ffmpeg
  font-awesome
  noto-fonts
  noto-fonts-color-emoji
  nerd-fonts.fira-code
  nerd-fonts.meslo-lg

  # Development tools
  curl
  direnv
  gh
  lazygit
  tree-sitter

  # Cloud-related tools and SDKs
#  docker
#  docker-compose
#  terraform
#  kubectl
#  awscli2

  # Programming languages and runtimes
  go
#  rustc
#  cargo
  openjdk8
  nodejs_22
#  nodejs_24

  # Python tooling
  (python3.withPackages (ps: with ps; [
    pip
    setuptools
    wheel
  ]))
  uv
  virtualenv

  # Java tooling
  maven
]
