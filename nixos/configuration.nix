{ config, pkgs, ... } @ inputs :

{
  imports = [
    inputs.xremap-flake.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';
  virtualisation.libvirtd.enable = true;

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

  # storage optimization
  nix = {
    optimise.automatic = true;
    optimise.dates = [ "03:45" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # ftp server
  services.vsftpd = {
    enable = true;
    localUsers = true;
    writeEnable = false;
    extraConfig = "pasv_enable=Yes\npasv_min_port=56250\npasv_max_port=56260";
  };

  # firewall
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [];
    allowedTCPPorts = [ 8080 7700 21 4983 11470 12470 ];
    allowedTCPPortRanges = [ { from = 56250; to = 56260; } ];
  };

  programs.river = {
    enable = true;
    extraPackages = [];
  };

  # services.displayManager.gdm.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.ly.settings = {
      hide_borders = "true";
  };
  services.desktopManager.gnome.enable = true;

  # disable gnome shit
  environment.gnome.excludePackages = (with pkgs; [
    gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-tour
    gnome-font-viewer gnome-logs gnome-maps gnome-music gnome-screenshot gnome-text-editor
    gnome-system-monitor gnome-weather gnome-disk-utility gnome-contacts
    gnome-photos gnome-connections gnome-color-manager gnome-console
    simple-scan totem yelp evince file-roller geary seahorse
    epiphany cheese baobab gedit decibels loupe snapshot eog
  ]);

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    mouse.naturalScrolling = true;
    touchpad.naturalScrolling = true;
  };

  # Enable sound with pipewire.
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
    extraGroups = [ "networkmanager" "wheel" "docker" "kvm" "adbusers" "libvirtd" ];
    shell = pkgs.zsh;
    packages = [];
  };

  fonts.packages = (with pkgs; [ cascadia-code nerd-fonts.jetbrains-mono ]);

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true; # minecraft
    permittedInsecurePackages = [ "openssl-1.1.1w" ]; # sublime4
  };

  programs = {
    adb.enable = true;
    direnv.enable = true;
    firefox.enable = true;
    zsh.enable = true;
  };

  virtualisation.docker.enable = true;

  # otros: discord, kitty, minecraft, stremio, nodejs, lf
  environment.systemPackages = with pkgs; [
     # desktop
     brave
     pcmanfm
     # wayland
     eww
     grim
     peaclock
     rofi-wayland
     rofi-bluetooth
     slurp
     wlr-randr
     wl-clipboard
     # boludeo
     spotify
     # software
     awscli2
     cargo
     gcc
     gh
     ghostty
     git
     gnumake
     go
     sqlite
     zed-editor
     # utils
     curl
     dig
     feh
     ffmpeg
     fzf
     gimp
     htop
     jq
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

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "24.05"; # dejar asi aunque suba version
}
