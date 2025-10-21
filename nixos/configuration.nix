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
    enable = true;
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

  # bluetooth
  hardware.bluetooth.enable = true;

  # network
  networking.networkmanager.enable = true;

  # firewall
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [];
    allowedTCPPorts = [ 8080 7700 21 4983 11470 12470 ];
    allowedTCPPortRanges = [ { from = 56250; to = 56260; } ];
  };

  # window managers
  programs.niri.enable = true;

  # display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session --remember --theme 'action=darkgray;border=black;container=black;prompt=gray;input=white'";
      };
    };
  };

  # keyring
  # services.gnome.gnome-keyring.enable = true;
  # security.pam.services.greetd.enableGnomeKeyring = true;

  # sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # music
  services.spotifyd.enable = true;

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
  };

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  programs = {
    adb.enable = true;
    direnv.enable = true;
    zsh.enable = true;
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
     # desktop
     brave
     nautilus
     pcmanfm
     # wayland
     eww
     dunst
     grim
     satty
     slurp
     swaylock-effects
     tofi
     wf-recorder
     wl-clipboard
     # software
     cargo
     gcc
     ghostty
     git
     gnumake
     go
     gopls
     opencode
     sqlite
     zed-editor
     # development
     tree-sitter
     typescript-language-server
     svelte-language-server
     # tui
     bluetui
     htop
     neomutt
     mutt-wizard
     wiremix
     yazi
     # utils
     curl
     dig
     ffmpeg
     fzf
     gimp3
     imv
     imagemagick
     jq
     nushell
     mpv
     openssl
     libqalculate
     lima
     ripgrep
     stow
     tmux
     unrar
     unzip
     vim
     wget
     yt-dlp
     zathura
     zip
  ];

  system.stateVersion = "24.05"; # dejar asi aunque suba version
}
