{ config, pkgs, ... } @ inputs :

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.xremap-flake.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hostName = "fausto-hp"; # Define your hostname.

  # Set your time zone and internationalisation properties
  time.timeZone = "America/Argentina/Buenos_Aires";
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

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # dwm
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm.overrideAttrs { src = ./dwm; };
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
    jack.enable = true; # estaba desactivado
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fausto = {
    isNormalUser = true;
    description = "Fausto Fusse";
    extraGroups = [ "networkmanager" "wheel" "docker" "kvm" "adbusers" ];
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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "openssl-1.1.1w" ]; # sublime4
    allowBroken = true; # minecraft
  };

  programs = {
    # adb.enable = true;
    direnv.enable = true;
    firefox.enable = true;
    zsh.enable = true;
  };

  virtualisation.docker.enable = true;

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
     cargo
     flyctl
     gcc
     gh
     git
     gnumake
     go
     jetbrains-toolbox
     nodejs
     sqlite
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
     neovim
     openssl
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

  system.stateVersion = "24.05"; # dejar asi aunque suba version
}
