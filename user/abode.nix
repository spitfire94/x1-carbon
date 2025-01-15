{
  lib,
  pkgs,
  config,
  ...
}: let
  badge = import ./badge.nix;
in {
  imports = [
    ./nushell.nix
    ./xdg-dirs.nix
    # ./shAliases.nix
  ];

  stylix = {
    enable = true;
    polarity = "dark";
    image = ./wallpaper/wp-03.jpg;
    targets.vscode.enable = false;
  };

  nixpkgs.config.allowUnfree = true;
  xsession.enable = true;
  news.display = "silent";
  home.username = badge.handle;
  home.stateVersion = "22.11";
  home.homeDirectory = "/home";
  home.extraOutputsToInstall = ["man" "doc" "info"];
  home.packages = with pkgs; [
    # nu_scripts-unstable
    nix-your-shell
    vivaldi
    cool-retro-term
    lolcat
    figlet
    fortune
    pipes-rs
    buku
    bukubrow
    grc
    helix
    bitwarden-cli
    nix-prefetch
    vlc
    szyszka
    # neovim
    bitwarden
    filelight
    # minecraft
    digikam
    gitkraken
    inkscape
    yt-dlp
    ffmpeg
    gtypist
    gnome-terminal
    just
    unzip
    gh
    gh-dash
    whois
    wemux
    base16-shell-preview
    with-shell
    google-cloud-sdk
    graphviz
    zgrviewer
    xdot
    dot2tex
    aria2
    axel
    anarchism
    monero-gui
    monero-cli
  ];

  home.sessionVariables = {
    PAGER = "most";
    EDITOR = "micro";
    VISUAL = "vscode";
    NIX_PAGER = "less";
    # GNUPGHOME = "${config.xdg.stateHome}/gnupg";
    NIXOS_CONFIG = "${config.home.homeDirectory}/project/thinkpad";
  };

  programs.gpg = {
    enable = true;
    # mutableKeys = false;
    # mutableTrust = false;
    publicKeys = [{ source = badge.pubkey; trust = "ultimate"; }];
    scdaemonSettings = {
      reader-port = "Yubico Yubikey";
      disable-ccid = true;
    };
    settings = {
      keyserver = "hkps://keys.openpgp.org";
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      require-cross-certification = true;
      no-symkey-cache = true;
      use-agent = true;
      throw-keyids = true;
    };
  };

  programs.git = {
    enable = true;
    userName = badge.realname;
    userEmail = badge.email;
    package = pkgs.gitAndTools.gitFull;
    signing = {
      key = badge.keyid;
      signByDefault = true;
    };
    aliases = {
      aa = "add --all";
      br = "branch";
      sr = "!git --no-pager subrepo";
      st = "status --branch --short";
      ca = "commit --amend --no-edit";
      cm = "commit --all --message";
      cq = "commit --all --allow-empty-message --no-edit"; # q for quick
      gr = "!git --no-pager log --graph --oneline --decorate --all";
      unstage = "reset HEAD --";
      revert = "log -1 HEAD";
      cpt = "crypt";
    };
  };

  programs.vscode = {
    enable = true;
    # package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      thenuprojectcontributors.vscode-nushell-lang
      rubymaniac.vscode-paste-and-indent
      brettm12345.nixfmt-vscode
      donjayamanne.githistory
      jnoortheen.nix-ide
      # oderwat.indent-rainbow
      # kamadorueda.alejandra
    ];
  };

  programs.micro = {
    enable = true;
    settings.autosu = true;
  };

  programs.helix = {
    enable = true;
  };

  programs.ssh.enable = true;
  programs.ssh.extraConfig = ''
    Host github.com
      User git
      ControlMaster no
      IdentitiesOnly yes
      IdentityFile ${./sshkey.pub}
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
  '';

  # needs tobe the authentication keygrip, not the usual certify
  home.file."${config.programs.gpg.homedir}/sshcontrol".text = 
    "7788B237AD5FB8A4B1956FAE43433A592C36E3D3";

  services.gpg-agent = {
    enable = true;
    maxCacheTtl = 120;
    defaultCacheTtl = 60;
    pinentryPackage = pkgs.pinentry-curses;
    sshKeys = [badge.keyid];
    enableScDaemon = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    extraConfig = ''
      ttyname $GPG_TTY
    '';
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    newSession = true;
    historyLimit = 9000;
    aggressiveResize = true;
    terminal = "xterm-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      # dracula
      better-mouse-mode
    ];
  };

  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;
  services.autorandr.enable = true;
  programs.xplr.enable = true;
  programs.fzf.enable = true;
  programs.lf.enable = true;
  programs.rbw.enable = true;
  programs.zoxide.enable = true;
  programs.home-manager.enable = true;
  programs.man.generateCaches = true;
  programs.nix-index.enable = true;
  programs.yt-dlp.enable = true;
  # services.syncthing.enable = true;
  # services.caffeine.enable = true;
  # programs.atuin.enable = true;
  # services.syncthing.tray.enable = true;
  # services.shellhub-agent.enable = true;

  fonts.fontconfig.enable = true;
  wayland.windowManager.sway.enable = true;
}
