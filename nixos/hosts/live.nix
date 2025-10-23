{ config, pkgs, ... } @ inputs :

{
  imports = [ (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix") ];

  networking.hostName = "faulive";

  system.userActivationScripts.dotfiles = {
    text = ''
      git clone git@github.com:faustofusse/dotfiles ~/.dotfiles
      stow -d ~/.dotfiles niri zsh ghostty bin apps dunst eww icons mpv nushell nvim opencode tmux tofi yazi zed
    '';
    deps = [];
  };
}
