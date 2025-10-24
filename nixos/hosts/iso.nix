{ config, pkgs, ... } @ inputs :

{
  imports = [ (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix") ];

  networking.hostName = "iso";

  isoImage.squashfsCompression = "gzip -Xcompression-level 2";

  environment.etc.dotfiles = { source = inputs.dotfiles; };

  environment.systemPackages = pkgs.lib.mkAfter [
    (pkgs.runCommand "alacritty-link" { } ''
     mkdir -p $out/bin
     ln -s ${pkgs.ghostty}/bin/ghostty $out/bin/alacritty
     '')
  ];

  system.userActivationScripts.dotfiles = {
    text = ''
      if [ ! -d "$HOME/.dotfiles" ]; then
        mkdir -p "$HOME/.dotfiles"
        cp -rL --no-preserve=mode "/etc/dotfiles/." "$HOME/.dotfiles/"
      fi
      ${pkgs.stow}/bin/stow -d "$HOME/.dotfiles" niri zsh ghostty bin apps dunst eww icons mpv nushell nvim opencode tmux tofi yazi zed
    '';
    deps = [];
  };
}
