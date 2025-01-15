{
  lib,
  pkgs,
  config,
  ...
}: let 
#  font-pack = pkgs.nerdfonts.override {
#    fonts = [
#      "FiraCode"
#      "FiraMono"
#      "Hack"
#      "Ubuntu"
#      "UbuntuMono"
#      #"OperatorMono"
#      #"CatographMono"
#    ];
#  };
  fontPack = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
in {

  stylix = {
    enable = true;
    polarity = "dark";
    image = ../user/wallpaper/wp-03.jpg;
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  hardware = {
    #pulseaudio.enable = true;
    #pulseaudio.package = pkgs.pulseaudioFull;
    graphics = {
      enable = true;
 #     extraPackages = with pkgs; [
 #       intel-media-driver
        #vaapiIntel
        #vaapiVdpau
#        libvdpau-va-gl
#      ];
    };
  };

  fonts = {
    fontconfig.enable = true;
    packages = fontPack;
  };

  programs.dconf.enable = true;
  services.dbus.packages = [pkgs.gcr];
  services.gnome.gnome-settings-daemon.enable = true;
  services.autorandr.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  environment.systemPackages = 
    (with pkgs.gnomeExtensions; [
      appindicator
      just-perfection
      vitals
      espresso
      gsconnect
      workspace-matrix
      tailscale-status
      solaar-extension
      # hotkeys-popup
      # clear-top-bar
      # zfs-status-monitor
      # lock-screen-message
      # gesture-improvements
      # tweaks-in-system-menu
      # system-action-hibernate
      order-gnome-shell-extensions
      unlock-dialog-background
      fullscreen-notifications
      dash2dock-lite
      # all-ip-addresses
      hide-top-bar
      thinkpad-thermal
      thinkpad-battery-threshold
      systemd-status
      systemd-manager
      super-key
      # strongdm
      space-bar
      # smartcard-lock
      quick-settings-tweaker
      peek-top-bar-on-fullscreen
      # openweather
      blur-my-shell
    ]) ++ (with pkgs; [cheese gnome-characters]);

  environment.gnome.excludePackages =
    (with pkgs; [
      # gnome-photos
      # gnome-tour
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
      # gnome-terminal
    ])
    ++ (with pkgs.gnome; [
      # gnome-characters
      # cheese # webcam tool
      # gedit # text editor
      # tali # poker game
      # iagno # go game
      # hitori # sudoku game
      # atomix # puzzle game
    ]);

}
