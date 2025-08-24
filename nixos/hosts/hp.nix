{ config, pkgs, ... } @ inputs :

{
  imports = [
    ../hardware/hp.nix
  ];

  networking.hostName = "fauhp"; # Define your hostname.
}
