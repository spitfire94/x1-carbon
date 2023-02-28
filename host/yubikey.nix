{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.ssh.startAgent = false;
  services.pcscd.enable = true;
  # services.yubikey-agent.enable = true;
  hardware.gpgSmartcards.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    age-plugin-yubikey
    pinentry-curses
    yubikey-manager
    yubikey-agent
    signing-party
    yubico-pam
    pcsctools
    fido2luks
    libfido2
    step-ca
    gpg-tui
    gnupg
    gpgme
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  services.openssh = {
    enable = true;
    settings.permitRootLogin = "no";
  };

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    # export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/yubikey-agent/yubikey-agent.sock"
    gpgconf --launch gpg-agent
  '';

  security.pam.yubico = {
    enable = true;
    mode = "challenge-response";
  };

  # programs.gnupg.agent = {
  #   enable = true;
  #   pinentryFlavor = "curses";
  #   enableSSHSupport = true;
  #   enableExtraSocket = true;
  #   enableBrowserSocket = true;
  # };
}
