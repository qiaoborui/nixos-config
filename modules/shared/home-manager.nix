{ config, pkgs, lib, ... }:

let name = "qiaoborui";
    user = "qiaoborui";
    email = "Mr.Strawberry@outlook.com"; in
{
  programs = {
    fish = {
    enable = true;
    shellAliases = {
      # Ripgrep alias
      search = "rg -p --glob '!node_modules/*'";

      # pnpm is a javascript package manager
      pn = "pnpm";
      px = "pnpx";

      # Use difftastic, syntax-aware diffing
      diff = "difft";

      # Always color ls and group directories
      ls = "ls --color=auto";
    };
    shellInit = ''
      # Load Nix daemon
      if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end

      # Add custom paths
      fish_add_path $HOME/.pnpm-packages/bin
      fish_add_path $HOME/.pnpm-packages
      fish_add_path $HOME/.npm-packages/bin
      fish_add_path $HOME/bin
      fish_add_path $HOME/.local/share/bin

      # Editor defaults
      set -gx EDITOR nvim
      set -gx VISUAL nvim

      # History configuration - ignore common commands
      set -gx fish_history_ignore 'pwd' 'ls' 'cd'
    '';
    functions = {
      # Nix shortcuts
      shell = ''
        nix-shell '<nixpkgs>' -A $argv[1]
      '';

      # SSH jump to fort and execute go command
      jump = ''
        if test (count $argv) -eq 0
          echo "用法: jump <go 参数>"
          return 1
        end

        ssh -tt fort "go $argv"
      '';
    };
    interactiveShellInit = ''
      # Bootstrap fisher if not present, then ensure z plugin is installed
      if not functions -q fisher
        echo "Installing fisher..." >&2
        if ${pkgs.curl}/bin/curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
          fisher install jorgebucaran/fisher >/dev/null 2>&1
        else
          echo "Failed to install fisher. Please check your network connection." >&2
        end
      end

      if functions -q fisher
        set -l plugins (fisher list 2>/dev/null)
        if not string match -q '*jethrokuan/z*' $plugins
          echo "Installing fisher plugin jethrokuan/z..." >&2
          fisher install jethrokuan/z >/dev/null 2>&1
        end
      end
    '';
  };

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      lfs = {
        enable = true;
      };
      settings = {
        user = {
          name = name;
          email = email;
        };
        init.defaultBranch = "main";
        core = {
	      editor = "vim";
          autocrlf = "input";
        };
        commit.gpgsign = false;
        pull.rebase = true;
        rebase.autoStash = true;
        url = {
          "git@git.huya.info:".insteadOf = "https://git.huya.info/";
          "git@git.huya.com:".insteadOf = "https://git.huya.com/";
        };
      };
    };

    vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline vim-airline-themes vim-startify vim-tmux-navigator ];
    settings = { ignorecase = true; };
    extraConfig = ''
      "" General
      set number
      set history=1000
      set nocompatible
      set modelines=0
      set encoding=utf-8
      set scrolloff=3
      set showmode
      set showcmd
      set hidden
      set wildmenu
      set wildmode=list:longest
      set cursorline
      set ttyfast
      set nowrap
      set ruler
      set backspace=indent,eol,start
      set laststatus=2
      set clipboard=autoselect

      " Dir stuff
      set nobackup
      set nowritebackup
      set noswapfile
      set backupdir=~/.config/vim/backups
      set directory=~/.config/vim/swap

      " Relative line numbers for easy movement
      set relativenumber
      set rnu

      "" Whitespace rules
      set tabstop=8
      set shiftwidth=2
      set softtabstop=2
      set expandtab

      "" Searching
      set incsearch
      set gdefault

      "" Statusbar
      set nocompatible " Disable vi-compatibility
      set laststatus=2 " Always show the statusline
      let g:airline_theme='bubblegum'
      let g:airline_powerline_fonts = 1

      "" Local keys and such
      let mapleader=","
      let maplocalleader=" "

      "" Change cursor on mode
      :autocmd InsertEnter * set cul
      :autocmd InsertLeave * set nocul

      "" File-type highlighting and configuration
      syntax on
      filetype on
      filetype plugin on
      filetype indent on

      "" Paste from clipboard
      nnoremap <Leader>, "+gP

      "" Copy from clipboard
      xnoremap <Leader>. "+y

      "" Move cursor by display lines when wrapping
      nnoremap j gj
      nnoremap k gk

      "" Map leader-q to quit out of window
      nnoremap <leader>q :q<cr>

      "" Move around split
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      "" Easier to yank entire line
      nnoremap Y y$

      "" Move buffers
      nnoremap <tab> :bnext<cr>
      nnoremap <S-tab> :bprev<cr>

      "" Like a boss, sudo AFTER opening the file to write
      cmap w!! w !sudo tee % >/dev/null

      let g:startify_lists = [
        \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
        \ { 'type': 'sessions',  'header': ['   Sessions']       },
        \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      }
        \ ]

      let g:startify_bookmarks = [
        \ '~/Projects',
        \ '~/Documents',
        \ ]

      let g:airline_theme='bubblegum'
      let g:airline_powerline_fonts = 1
      '';
     };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
          "/home/${user}/.ssh/config_external"
        )
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
          "/Users/${user}/.ssh/config_external"
        )
      ];
      matchBlocks = {
        "*" = {
          # Set the default values we want to keep
          sendEnv = [ "LANG" "LC_*" ];
          hashKnownHosts = true;
        };
        "github.com" = {
          identitiesOnly = true;
          identityFile = [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
              "/home/${user}/.ssh/id_ed25519_github"
            )
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
              "/Users/${user}/.ssh/id_ed25519_github"
            )
          ];
        };
      };
    };

    tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
      prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
           set -g @tmux_power_theme 'gold'
        '';
      }
      {
        plugin = resurrect; # Used by tmux-continuum

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
    terminal = "screen-256color";
    prefix = "C-a";
    escapeTime = 10;
    historyLimit = 50000;
    extraConfig = ''
      # Remove Vim mode delays
      set -g focus-events on

      # Enable full mouse support
      set -g mouse on

      # -----------------------------------------------------------------------------
      # Key bindings
      # -----------------------------------------------------------------------------

      unbind '"'
      unbind %

      # Split panes, vertical or horizontal
      bind-key - split-window -v
      bind-key _ split-window -h

      # Move around panes with vim-like bindings (h,j,k,l)
      bind-key -n M-k select-pane -U
      bind-key -n M-h select-pane -L
      bind-key -n M-j select-pane -D
      bind-key -n M-l select-pane -R

      # Switch windows with Ctrl-h/l (previous/next) with wrap around
      bind-key -r h select-window -t :-
      bind-key -r l select-window -t :+

      # Smart pane switching with awareness of Vim splits.
      # This is copy paste from https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
      '';
    };
  };

  home.activation.bootstrapAstroNvim =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      target="${config.home.homeDirectory}/.config/nvim"
      sentinel="$target/.nix-astrovim"
      if [ -f "$sentinel" ]; then
        echo "AstroNvim already bootstrapped at $target"
      else
        if [ -d "$target" ] || [ -f "$target" ]; then
          backup="$target.bak-$(date +%s)"
          echo "Backing up existing $target to $backup"
          mv "$target" "$backup"
        fi
        echo "Cloning AstroNvim template..."
        ${pkgs.git}/bin/git clone --depth 1 https://github.com/AstroNvim/template "$target"
        rm -rf "$target/.git"
        echo "Bootstrapped AstroNvim at $target"
        echo "managed by nix" > "$sentinel"
      fi
    '';
}
