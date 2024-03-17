{
  lib,
  pkgs,
  config,
  ...
}: 
with lib;
let

  environ = pkgs.writeText "env.json" "${builtins.toJSON config.home.sessionVariables}";

  # ohmyposhInit = pkgs.runCommand "oh-my-posh.nu" {} ''
  #   ${pkgs.oh-my-posh}/bin/oh-my-posh init --print nu \
  #     --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/${config.programs.oh-my-posh.useTheme}.omp.json \
  #     > $out
  # '';

  starshipInit = ''
    $env.STARSHIP_SHELL = "nu"
    $env.STARSHIP_SESSION_KEY = (random chars -l 16)
    $env.PROMPT_MULTILINE_INDICATOR = (^starship prompt --continuation)
    $env.PROMPT_INDICATOR = ""

    $env.PROMPT_COMMAND = {||
      let width = (term size).columns
      ^starship prompt $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
    }

    $env.PROMPT_COMMAND_RIGHT = {||
      let width = (term size).columns
      ^starship prompt --right $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
    }
  '';

in {

  home.packages = with pkgs; [ nu_scripts carapace starship oh-my-posh ];

  home.file."${config.xdg.configHome}/starship.toml".source =
    pkgs.runCommand "starship.toml" {} "${pkgs.starship}/bin/starship preset pure-preset > $out";
  
  programs.oh-my-posh = {
    enable = true;
    useTheme = "cobalt2";
  };

  programs.nushell = {
    enable = true;
    package = pkgs.nushellFull;

    extraEnv = ''
      open ${environ} | load-env

      # $\{starshipInit}
      # source $\{ohmyposhInit}

      $env.GPG_TTY = (tty)
      $env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
    '';

    extraConfig = ''
      $env.config = {
        show_banner: false
        render_right_prompt_on_last_line: true
        history: {
          max_size: 100000
          sync_on_enter: true
          file_format: "sqlite"
        }
        completions: {
          algorithm: "fuzzy"
          # external: {
          #   enable: true
          #   completer: {|spans| carapace $spans.0 nushell $spans | from json }
          # }
        }
        hooks: {
          pre_prompt: [{
            code: "
              let direnv = (direnv export json | from json)
              let direnv = if ($direnv | is-empty) { {} } else { $direnv }
              $direnv | load-env
            "
          }]
        }
      }

      if not (which bat | is-empty) {
        alias cat = ^bat 
      }

      if (which doas | is-empty) {
        alias doas = ^sudo
      } else {
        alias sudo = ^doas 
      }

      alias vw = bat
      alias pg = most
      alias ed = micro
      alias rl = direnv reload
      alias vc = git # ver ctl
      alias ll = ls -l
      alias la = ls -a
      alias lt = ^eza -M -F -a --long --header --group-directories-first --sort=type --total-size --git-repos --git --git-ignore -I '.git*' --tree --level=6

      # Dvorak typist practice
      alias dvtyp = gtypist --personal-best --scoring=cpm --max-error=2.0 --show-errors d.typ

      # Update flake inputs of nixos configuration
      alias nixos-up = doas nix flake update --flake /etc/nixos

      # Rebuild and enable nixos configuration
      alias nixos-rb = doas nixos-rebuild boot --impure --flake /etc/nixos

      # Rebuild and activate nixos configuration
      alias nixos-sw = doas nixos-rebuild switch --impure --flake /etc/nixos

      # Mount a filesystem without needing an existing directory
      alias mnt = doas mount --mkdir

      # Unmount all filesystems at and under the target
      alias ejc = doas umount --quiet --recursive

      # Create one or more directories
      alias mkd = mkdir
      
      # Create directory and touch file
      def mkf [...trgs] {
        $trgs | each {|trg| $trg | path dirname | mkd $in; touch $trg }
        ignore
        }

      # simpler linking
      alias ln-h = ln     # hard link 
      alias ln-s = ln -s  # soft link
      alias ln-r = ln -sr # rela link

      # remove a symbolic link
      alias rmln = unlink

      # force remove anything and everything
      alias rmrf = rm -rf

      # Reload the environment shell
      alias rlsh = exec $env.SHELL

      # Keep the system awake while running a command
      alias wake-lock = systemd-inhibit --why='Allow long running process to finish' --what=idle:sleep:handle-lid-switch --

      # Run rsync with commonly used flags while staying awake
      alias sync-copy = wake-lock rsync -ah --partial --no-inc-recursive --info=progress2

      # Work with zed filesystems
      alias zfs = doas zfs

      # Work with zfs datasets
      alias zds = doas zpool

      # Set a zfs property when given a value and get it otherwise
      def zet [trg key val?] {
        if ($val == null) {
          zfs get -Ho value $key $trg
        } else {
          zfs set $"($key)=($val)" $trg
        }
      }

      # Replace chunks of a repeating character with a single one
      def "str squeeze" [char: string = " "] {
        $in | tr -s $char
      }
      
      # Turn an oil style regular expression into standard form
      def eggex [...expr] {
        oil -c $"write $[/ ($expr | str join) /]"
      }

      # Run luks v2 cryptsetup sub-commands
      def --wrapped luks [task: string ...args] {
        doas cryptsetup --batch-mode --type=luks2 $"luks($task | str capitalize)" $args
      }

      # Generate a namespaced uuid
      def nsidgen [seed: string base: string = "@oid"] {
        uuidgen --sha1 --namespace $base --name $seed
      }
    '';
  };

}
