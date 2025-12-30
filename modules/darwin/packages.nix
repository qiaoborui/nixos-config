{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  # macOS utilities
  dockutil
  ice-bar
  stats

  # Virtualization
  utm

  # IDEs
  jetbrains.idea
  jetbrains.goland

  # Productivity
  obsidian
]
