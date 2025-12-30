{ user, config, pkgs, ... }:

let
  xdg_configHome = "${config.users.users.${user}.home}/.config";
  xdg_dataHome   = "${config.users.users.${user}.home}/.local/share";
  xdg_stateHome  = "${config.users.users.${user}.home}/.local/state"; in
{
  ".ssh/config" = {
    text = ''
      Include ~/.orbstack/ssh/config

      Host dev
        HostName 172.21.44.10
        User borui
        IdentityFile ~/.ssh/id_rsa

      Host orb
        HostName orb

      Host *
        AddKeysToAgent yes

      Host git.huya.info
        HostName git.huya.info
        Port 32200
        User git

      Host git.huya.com
        HostName git.huya.com
        Port 32200
        User git
      
      Host dev24
        HostName 10.132.22.79
        User root
        IdentityFile "~/.ssh/Identify"
        Port 22

      Host dev16
        HostName 10.132.23.55
        User root
        IdentityFile "~/.ssh/Identify"
        Port 22

      Host fort
        HostName fort.huya.com
        Port 32200
        User qiaoborui
        IdentityFile "~/.ssh/Identify"
        ForwardAgent yes
        AddKeysToAgent yes

      Host 3.147.46.85
        HostName 3.147.46.85
        User root

      Host 209.170.67.168
        HostName 209.170.67.168
        User root
        Port 60254

      Host 209.170.67.171
        HostName 209.170.67.171
        User root
        Port 60254

      Host ubuntu
        HostName ubuntu.int.borry.org
        User borui

      Host cc
        HostName 43.130.251.4
        User strawberry
        Port 6000

      Host pi
        HostName pi.borry.org
        User pi
        proxycommand /opt/homebrew/bin/cloudflared access ssh --hostname %h

      # Host *
      #   IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };

}
