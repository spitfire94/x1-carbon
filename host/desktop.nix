{
  lib,
  pkgs,
  config,
  ...
}: let 
  font-pack = pkgs.nerdfonts.override {
    fonts = [
      "FiraCode"
      "FiraMono"
      "Hack"
      "Ubuntu"
      "UbuntuMono"
    ];
  };
in {

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  hardware = {
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  fonts = {
    fontconfig.enable = true;
    fonts = [font-pack];
  };

  sound.enable = true;
  programs.dconf.enable = true;
  services.dbus.packages = [pkgs.gcr];
  services.gnome.gnome-settings-daemon.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  services.udev.packages = with pkgs; [
    gnome.gnome-settings-daemon
  ];

  environment.systemPackages = 
    with pkgs.gnomeExtensions; [
      appindicator
      just-perfection
      vitals
      espresso
      gsconnect
      taildrop-send
      workspace-matrix
      tailscale-status
      hotkeys-popup
      clear-top-bar
      zfs-status-monitor
      lock-screen-message
      gesture-improvements
      tweaks-in-system-menu
      system-action-hibernate
      order-gnome-shell-extensions
      unlock-dialog-background
      fullscreen-notifications
      dash2dock-lite
      all-ip-addresses
    ] ++ [pkgs.gnome.gnome-characters];

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      gnome-terminal
      # gnome-characters
      gnome-music
      cheese # webcam tool
      gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);

}