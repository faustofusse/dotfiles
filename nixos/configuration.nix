{ config, pkgs, ... } @ inputs :

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.xremap-flake.nixosModules.default
    ];

  # remaps
  services.xremap = {
    watch = true;
    withX11 = true;
    config = {
      modmap = [
        { remap = { "ALT_L" = "CTRL_L"; }; }
        { remap = { "SUPER_L" = "ALT_L"; }; }
        { remap = { "CTRL_L" = "SUPER_L"; }; }
      ];
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fausto-hp"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Argentina/Buenos_Aires";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_AR.UTF-8";
    LC_IDENTIFICATION = "es_AR.UTF-8";
    LC_MEASUREMENT = "es_AR.UTF-8";
    LC_MONETARY = "es_AR.UTF-8";
    LC_NAME = "es_AR.UTF-8";
    LC_NUMERIC = "es_AR.UTF-8";
    LC_PAPER = "es_AR.UTF-8";
    LC_TELEPHONE = "es_AR.UTF-8";
    LC_TIME = "es_AR.UTF-8";
  };

  # use gnome keyring
  security.pam.services.gdm.enableGnomeKeyring = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # dwm
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm.overrideAttrs { src = ../dwm; };
    };

    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  # compositor
  services.picom = {
    enable = true;
    # no anda creo
    fadeExclude = [ "window_type *= 'menu'" ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    mouse.naturalScrolling = true;
    touchpad.naturalScrolling = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fausto = {
    isNormalUser = true;
    description = "Fausto Fusse";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # programs
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.direnv.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # docker
  virtualisation.docker.enable = true;

  # permito esto para sublime4
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];

  # permito esto para minecraft
  nixpkgs.config.allowBroken = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
     # desktop
     brave
     discord
     kitty
     libreoffice
     rofi
     # boludeo
     minecraft
     spotify
     stremio
     xournalpp
     # software
     sqlc # mover a flakes
     templ # mover a flakes
     goose # mover a flakes
     android-tools
     cargo
     flutter
     flyctl
     gcc
     gh
     git
     gnumake
     go
     jetbrains-toolbox
     nodejs
     neovim
     sqlite
     sublime4
     turso-cli
     # utils
     curl
     dig
     feh
     ffmpeg
     fzf
     gimp
     lf
     maim
     mpv
     ncdu
     ripgrep
     stow
     tmux
     unzip
     vim
     wget
     xsel
     zathura
     zip
  ];

  # version - dejar asi
  system.stateVersion = "24.05";
}
