{ config, pkgs, ... } @ inputs :

{
  imports = [
    ../hardware/lenovo.nix
  ];

  networking.hostName = "faulenovo"; # Define your hostname.
}
