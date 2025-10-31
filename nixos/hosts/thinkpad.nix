{ config, pkgs, ... } @ inputs :

{
  imports = [
    ../hardware/thinkpad.nix
  ];

  networking.hostName = "thinkpad"; # Define your hostname.

  system.userActivationScripts.dotfiles = {
    text = ''
      ${pkgs.stow}/bin/stow -d "$HOME/.dotfiles" niri zsh ghostty bin apps dunst eww icons mpv nushell nvim opencode tmux tofi yazi zed
    '';
    deps = [];
  };
}
