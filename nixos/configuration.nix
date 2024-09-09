{ config, pkgs, ... } @ inputs :

{
  imports = [
    inputs.xremap-flake.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  services.xremap = {
    watch = true;
    withWlroots = true;
    config = {
      modmap = [
        { remap = { "ALT_L" = "CTRL_L"; }; }
        { remap = { "CTRL_L" = "ALT_L"; }; }
      ];
    };
  };

  services.vsftpd = {
    enable = true;
    localUsers = true;
    writeEnable = false;
    extraConfig = "pasv_enable=Yes\npasv_min_port=56250\npasv_max_port=56260";
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [];
    allowedTCPPorts = [ 8080 7700 21 4983 11470 12470 ];
    allowedTCPPortRanges = [ { from = 56250; to = 56260; } ];
  };

  services.xserver = {
    enable = true;
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  programs.river.enable = true;

  # disable gnome shit
  environment.gnome.excludePackages = (with pkgs.gnome; [
    baobab cheese eog epiphany simple-scan totem yelp evince file-roller geary seahorse    
    gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts
    gnome-font-viewer gnome-logs gnome-maps gnome-music gnome-screenshot
    gnome-system-monitor gnome-weather gnome-disk-utility
  ]) ++ (with pkgs; [
    gedit gnome-photos gnome-connections
  ]);

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
    jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fausto = {
    isNormalUser = true;
    description = "Fausto Fusse";
    extraGroups = [ "networkmanager" "wheel" "docker" "kvm" "adbusers" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
     pcmanfm
     # wayland
     eww
     grim
     rofi-wayland
     rofi-bluetooth
     slurp
     wlr-randr
     wl-clipboard
     # boludeo
     minecraft
     spotify
     stremio
     xournalpp
     # software
     awscli2
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
     htop
     jq
     lf
     mpv
     ncdu
     neofetch
     neovim
     openssl
     libqalculate
     ripgrep
     stow
     tmux
     unzip
     vim
     wget
     yazi
     zathura
     zip
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "24.05"; # dejar asi aunque suba version
}
