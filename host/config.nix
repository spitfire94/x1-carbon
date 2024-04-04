{
  pkgs,
  inputs,
  modulesPath,
  ...
}:
let badge = import ../user/badge.nix;
in {
  system.stateVersion = "22.11";
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./accounts.nix
    ./android.nix
    ./bootdev.nix
    ./desktop.nix
    ./yubikey.nix
  ];

  bootDevice = {
    serial = "INTEL_SSDPEKKF512G8L_PHHP9341058E512C";
    description = "personal pet machine";
    chassis = "laptop";
    handle = "carbon";
    owner = "spitfire";
    swapSize = "16G";
    stowSize = "8G";
    bootSize = "2G";
  };

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
    permittedInsecurePackages = [ "nix-2.16.2" ];
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  location.provider = "geoclue2";

  nix = {
    package = pkgs.nixUnstable;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      home-manager.flake = inputs.home-mgr;
      flake-parts.flake = inputs.flake-parts;
    };
    settings = {
      warn-dirty = false;
      use-cgroups = true;
      auto-optimise-store = true;
      accept-flake-config = true;
      always-allow-substitutes = true;
      use-xdg-base-directories = true;
      system-features = ["big-parallel" "benchmark" "kvm" "recursive-nix"];
      trusted-users = ["root" badge.handle];
      experimental-features = [
        "recursive-nix" "ca-derivations"
        "nix-command" "flakes" "repl-flake"
        "configurable-impure-env" "cgroups"
        "dynamic-derivations" "auto-allocate-uids"
        ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  environment.systemPackages =
    with pkgs; [
      nixUnstable
      gnome.dconf-editor
      # dracula-theme
      killall
      nushell
      expect
      lolcat
      figlet
      fortune
      micro
      curl
      wget
      axel
      rsync
      rclone
      zip
      lsd
      oil
      eza
      fish
      elvish
      xonsh
      elixir
      ripgrep
      zstd
      file
      lsof
      jq
      yq
      jo
      bc
      lf
      gh
      tmux
      mosh
      direnv
      docopts
      bcal
      bat
      zfs
      exfat
      gocryptfs
      gptfdisk
      parted
      gitui
      bitwarden-cli
      tree
      sshfs
      most
      nixd
      nil
      nix-du
      nix-info
      nix-index
      nix-search-cli
      nix-output-monitor
      alejandra
      manix
      git
      git-crypt
      git-subrepo
      findutils
      helix
      borgbackup
      ncdu
      ddrescue
      rename
      cod
      btop
      broot
      tiptop
      catcli
      # devenv
      kmod
      lynx
    ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-intel"];
  hardware.cpu.intel.updateMicrocode = true;

  documentation = {
    nixos.enable = true;
    info.enable = true;
    man.enable = true;
    enable = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 40;
    priority = 20;
  };

  programs.mosh.enable = true;
  services.tailscale.enable = true;
  services.syncthing.enable = true;
  services.fwupd.enable = true;
  services.upower.enable = true;
  services.logind.lidSwitch = "hybrid-sleep";
  services.logind.lidSwitchExternalPower = "suspend"; #ignore
  # services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

  # prevent usb auto mount
  services.udev.extraRules = ''
    DRIVERS=="usb-storage", SUBSYSTEMS=="usb", ENV{UDISKS_AUTO}="0", ENV{UDISKS_IGNORE}="1"
  '';

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "dvorak";
    libinput.enable = true;
  };

  services.kubo = {
    enable = true;
    localDiscovery = true;
    startWhenNeeded = true;
  };

  console = {
    packages = [pkgs.terminus_font];
    earlySetup = true;
    useXkbConfig = true;
  };

  networking = {
    domain = "stargem.xyz";
    networkmanager.enable = true;
    firewall.checkReversePath = "loose";
  };

  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;

  security.doas.enable = true;
}
