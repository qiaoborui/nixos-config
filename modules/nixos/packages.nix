{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  # Security and authentication
  yubikey-agent
  keepassxc

  # App and package management
  appimage-run
  home-manager

  # Build tools
  gnumake
  cmake

  # Audio tools
  pavucontrol # Pulse audio controls

  # App launcher and window tools
  rofi
  rofi-calc
  libtool # for Emacs vterm

  # Screenshot and recording tools
  flameshot

  # Text and terminal utilities
  tree
  unixtools.ifconfig
  unixtools.netstat
  xclip # For the org-download package in Emacs
  xorg.xwininfo # Provides a cursor to click and learn about windows
  xorg.xrandr

  # File and system utilities
  fontconfig
  inotify-tools # inotifywait, inotifywatch - For file system events
  libnotify
  pcmanfm # File browser
  sqlite
  xdg-utils

  # Browsers
  firefox
  google-chrome

  # PDF viewer
  zathura
  
  # Music and entertainment
]
