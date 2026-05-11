{ config, pkgs, lib, ... } @ inputs :

let
  opencode-latest = pkgs.buildFHSEnv {
    name = "opencode";
    runScript = "${pkgs.stdenv.mkDerivation {
      pname = "opencode-unwrapped";
      version = "1.14.19";

      src = pkgs.fetchurl {
        url = "https://github.com/anomalyco/opencode/releases/download/v1.14.19/opencode-linux-x64.tar.gz";
        sha256 = "sha256-jLEXI84OyC4rb/miNWsSwvTEqVoIe6CjAEsZ8WeVFEA=";
      };

      sourceRoot = ".";

      installPhase = ''
        mkdir -p $out/bin
        cp opencode $out/bin/opencode
        chmod +x $out/bin/opencode
      '';
    }}/bin/opencode";

    targetPkgs = pkgs: with pkgs; [
      glibc
      zlib
    ];
  };
in
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
  systemd.services.virt-secret-init-encryption.enable = false;

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
  networking.wireless.iwd.enable = true;
  networking.wireless.userControlled.enable = true;
  networking.wireless.networks."Personal Wifi998 5.8GHz".pskRaw = "e80bb6cc6b704dbbc25a18f3d9d76a99e86c9ed4b129366a184db3825cf760df";
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [];
    allowedTCPPorts = [ 8080 7700 21 4983 11470 12470 ];
    allowedTCPPortRanges = [ { from = 56250; to = 56260; } ];
  };

  # window managers
  programs.niri.enable = true;

  # Enable dconf for system settings
  programs.dconf.enable = true;

  # Set dark mode preference for Niri and desktop apps
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  }];

  # display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session --remember --theme 'action=darkgray;border=black;container=black;prompt=gray;input=white'";
      };
    };
  };

  # fix logs que aparecen arriba de tuigreet
  systemd.services.greetd = {
    unitConfig = {
      After = lib.mkOverride 0 [ "multi-user.target" ];
    };
    serviceConfig = {
      Type = "idle";
    };
  };

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

  users.users.fausto = {
    isNormalUser = true;
    description = "Fausto Fusse";
    extraGroups = [ "networkmanager" "wheel" "docker" "kvm" "adbusers" "libvirtd" ];
    shell = pkgs.zsh;
    packages = [];
    hashedPassword = "$6$lLdaLqycDmVB8Bh7$pU0KCGUlfG6lbVCCqTor0LetXmZNZEn8XhkZ757.S.yFIHSYQsc06vuu2G1NC1NVTvG0HSwu0mb4lz6DiJiW4.";
  };

  fonts.packages = (with pkgs; [ cascadia-code nerd-fonts.jetbrains-mono ]);

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true; # minecraft
  };

  programs = {
    direnv.enable = true;
    zsh.enable = true;
  };

  virtualisation.docker.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    # "qtwebengine-5.15.19"  # No longer needed - using stremio-linux-shell instead
  ];

  environment.systemPackages = with pkgs; [
     # desktop
     brave
     nautilus
     pcmanfm
      stremio-linux-shell
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
     xwayland-satellite
     # software
     cargo
     gcc
     ghostty
     git
     gnumake
     go
     gopls
     neovim
      opencode-latest
     sqlite
     zed-editor
     # development
     tree-sitter
     typescript-language-server
     svelte-language-server
     # tui
     bluetui
     htop
     impala
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
