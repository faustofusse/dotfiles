{ config, pkgs, ... } @ inputs :

{
  imports = [ (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix") ];

  networking.hostName = "faulive";

  # Copy dotfiles into the ISO
  environment.etc."dotfiles" = {
    source = ../../.;  # This copies your entire dotfiles repo to /etc/dotfiles
    mode = "0755";
  };

  # Deploy dotfiles on first boot
  system.userActivationScripts.dotfiles = {
    text = ''
      # Copy dotfiles from /etc to home if not already present
      if [ ! -d "$HOME/.dotfiles" ]; then
        cp -r /etc/dotfiles $HOME/.dotfiles
        chmod -R u+rw $HOME/.dotfiles
      fi
      
      # Use stow to deploy the dotfiles
      cd $HOME/.dotfiles
      ${pkgs.stow}/bin/stow -d . niri zsh ghostty bin apps dunst eww icons mpv nushell nvim opencode tmux tofi yazi zed
    '';
    deps = [];
  };
}
