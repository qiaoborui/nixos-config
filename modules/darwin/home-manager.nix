{ config, pkgs, lib, home-manager, ... }:

let
  user = "qiaoborui";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    taps = [
      "oven-sh/bun"
      "tw93/tap"
    ];
    brews = [
      "sl"
      "jabba"
      "bun"
      "tw93/tap/mole"
    ];
    # onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)

    masApps = {
      # "wireguard" = 1451685025;
      "企业微信" = 1189898970;
      "infuse" = 1136220934;
      "微信" = 836500024;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:
      let
        sharedConfig = import ../shared/home-manager.nix { inherit config pkgs lib; };
      in
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix {};
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];

          stateVersion = "23.11";
        } // sharedConfig.home;

        programs = sharedConfig.programs;

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      username = user;
      entries = [
        { path = "/Applications/Arc.app/"; }
        { path = "/Applications/Telegram.app/"; }
        { path = "/System/Applications/Messages.app/"; }
        { path = "${pkgs.obsidian}/Applications/Obsidian.app/"; }
        { path = "/Applications/Wave.app/"; }
        { path = "/Applications/iTerm.app/"; }
        { path = "/System/Applications/Music.app/"; }
        { path = "/Applications/Surge.app/"; }
        { path = "/Applications/Visual Studio Code.app/"; }
        { path = "${pkgs.jetbrains.idea-ultimate}/Applications/IntelliJ IDEA.app/"; }
        { path = "/System/Applications/System Settings.app/"; }
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
