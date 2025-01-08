{ config, pkgs, lib, ... }:

let name = "Adam Bray";
    user = "adambray";
    email = "adam.bray@gmail.com"; in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./config;
        file = "p10k.zsh";
      }
    ];
    shellAliases =
      {
        update = ''
          cd ~/workspace/system-new/ \
            && rm ~/.ssh/config \
            && nix run .#build-switch \
            && exec $SHELL
        '';
      };
    profileExtra = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export GOPATH=$HOME/go

      # Define variables for directories
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH
      export PATH=$HOME/Library/Python/3.9/bin:$PATH
      export PATH=$HOME/.local/bin/:$PATH
      export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS":$PATH
      export PATH="/Applications/Rider.app/Contents/MacOS":$PATH
      export PATH="/Applications/Webstorm.app/Contents/MacOS":$PATH
      export PATH=$GOPATH/bin:$PATH

      export EDITOR=nvim

      # Some MO repos use this env var to enable flakes via direnv
      export AUTO_ENABLE_FLAKES=true
      
      # nix shortcuts
      shell() {
          nix-shell '<nixpkgs>' -A "$1"
      }

      eval "$(fasd --init auto)"
      
      # Use difftastic, syntax-aware diffing
      # alias diff=difft

      # Always color ls and group directories
      alias ls='ls --color=auto'
    '';
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "miloshadzic";
    };
  };

  git = {
    enable = true;
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYPlWUM3LaYEP8hKUWCaixu6X+yNq96v1YIC9Diu+M2";
      signByDefault = true;
    };


    extraConfig = {
      init.defaultBranch = "main";
            push = {
        autoSetupRemote = true;
      };
      diff = {
        algorithm = "histogram";
      };
      branch = {
        sort = "committerdate";
      };
      rerere = {
        enabled = true;
      };
      merge = {
        conflictstyle = "zdiff3";
      };
      pull.rebase = true;
      rebase.autoStash = true;
      gpg = { format = "ssh"; };
      "gpg \"ssh\"" = lib.mkIf pkgs.stdenv.isDarwin {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };
  };

   direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };


  alacritty = {
    enable = true;
    settings = {
      cursor = {
        style = "Block";
      };

      window = {
        opacity = 1.0;
        padding = {
          x = 24;
          y = 24;
        };
      };

      font = {
        normal = {
          family = "MesloLGS NF";
          style = "Regular";
        };
        size = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 10)
          (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 14)
        ];
      };

      dynamic_padding = true;
      decorations = "full";
      title = "Terminal";
      class = {
        instance = "Alacritty";
        general = "Alacritty";
      };

      colors = {
        primary = {
          background = "0x1f2528";
          foreground = "0xc0c5ce";
        };

        normal = {
          black = "0x1f2528";
          red = "0xec5f67";
          green = "0x99c794";
          yellow = "0xfac863";
          blue = "0x6699cc";
          magenta = "0xc594c5";
          cyan = "0x5fb3b3";
          white = "0xc0c5ce";
        };

        bright = {
          black = "0x65737e";
          red = "0xec5f67";
          green = "0x99c794";
          yellow = "0xfac863";
          blue = "0x6699cc";
          magenta = "0xc594c5";
          cyan = "0x5fb3b3";
          white = "0xd8dee9";
        };
      };
    };
  };

  neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  ssh = {
    enable = true;
    controlPath = "none";
    matchBlocks."github.com" = {
      extraOptions = {
        IdentityAgent = "~/.1password/agent.sock";
      };
    };
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      # vim-tmux-navigator
      sensible
      better-mouse-mode
      # yank
      # prefix-highlight
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
    # terminal = "screen-256color";
    # prefix = "C-x";
    # escapeTime = 10;
    # historyLimit = 50000;
    extraConfig = ''
        set-option -g default-shell /Users/adambray/.nix-profile/bin/zsh
        # Some tweaks to the status line
        set -g status-right "%b %d %Y | %l:%M %p"
        set -g status-justify centre
        set -g status-left-length 60

        # Highlight active window
        set -g window-status-current-style fg=red,bg=black,bold

        set-option -g renumber-windows on

        # hjkl pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Enable RGB colour if running in xterm(1)
        # set-option -sa terminal-overrides ",xterm*:Tc"

        # work with upterm
        set-option -ga update-environment " UPTERM_ADMIN_SOCKET"

        # useful when pairing on different sized screens
        set-window-option -g window-size smallest

        # Change the default $TERM to xterm-256color
        # set -g default-terminal "xterm-256color"

        # No bells at all
        set -g bell-action none

        # Use focus events
        set -g focus-events on

        # Keep current path when creating new panes/windows
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        # Use vim keybindings in copy mode
        setw -g mode-keys vi

        # Setup 'v' to begin selection as in Vim
        bind-key -T copy-mode-vi v send -X begin-selection

        bind-key -T copy-mode-vi y send -X copy-selection
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

        # Update default binding of `Enter` to also use copy-pipe
        unbind -T copy-mode-vi Enter
        bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"

        # Turn the mouse on
        set -g mouse on
        bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe "pbcopy"

        # Set window notifications
        setw -g monitor-activity off
        set -g visual-activity off

        # reduce esc time for vim
        set -g escape-time 10

        # Automatically set window title
        # setw -g automatic-rename
        set -g pane-border-status top
        setw -g pane-border-format ' #P #T : #{pane_current_path} '

        # Display pane numbers longer
        set -g display-panes-time 4000

        # Display status bar messages longer
        set-option -g display-time 2000

        # Start pane and window numbering at 1 instead of 0
        setw -g base-index 1
        setw -g pane-base-index 1

        # pane border colors
        set -g pane-border-style fg='#31AFD4'
        set -g pane-active-border-style fg='#FF007F'

        # List of plugins
        # set -g @plugin 'tmux-plugins/tpm'
        # set -g @plugin 'christoomey/vim-tmux-navigator'
        # TODO plugin doesn't currently detect lvim, so doing it manually here:
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'"
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

      #    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
      #    run '~/.tmux/plugins/tpm/tpm'
      '';
    };
}
