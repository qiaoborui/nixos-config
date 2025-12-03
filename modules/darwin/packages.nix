{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  dockutil
  ice-bar
  stats
  jetbrains.idea-ultimate
  obsidian
]
