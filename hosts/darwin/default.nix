{ agenix, config, pkgs, ... }:

let user = "qiaoborui"; in

{

  imports = [
    ../../modules/darwin/secrets.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
     agenix.darwinModules.default
  ];

  # Setup user, packages, programs
  # nix configuration is handled by nix-darwin automatically
  # nix = {
  #   package = pkgs.nix;
  #   settings = {
  #     trusted-users = [ "@admin" "${user}" ];
  #     substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
  #     trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  #   };
  #
  #   gc = {
  #     automatic = true;
  #     interval = { Weekday = 0; Hour = 2; Minute = 0; };
  #     options = "--delete-older-than 30d";
  #   };
  #
  #   extraOptions = ''
  #     experimental-features = nix-command flakes
  #   '';
  # };

  # Turn off NIX_PATH warnings now that we're using flakes

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    agenix.packages."${pkgs.system}".default
    jetbrains.idea-ultimate
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  # Make sure fish is an allowed login shell for the system user config
  environment.shells = [ pkgs.fish ];

  # Ensure the default shell is switched to fish on activation
  system.activationScripts.setFishShell = {
    text = ''
      current_shell="$(/usr/bin/dscl . -read /Users/${user} UserShell 2>/dev/null | /usr/bin/awk '{print $2}')"
      target_shell="/run/current-system/sw/bin/fish"
      if [ "$current_shell" != "$target_shell" ]; then
        /usr/bin/chsh -s "$target_shell" ${user} || true
      fi
    '';
  };

  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        show-recents = true;
        launchanim = true;
        orientation = "bottom";
        tilesize = 64;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };

  programs.fish.enable = true;
}
