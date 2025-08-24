{ config, pkgs, ... } @ inputs :

{
  imports = [
    ../hardware/mbp.nix
    inputs.nixos-hardware.nixosModules.apple-t2
  ];

  networking.hostName = "faumbp"; # Define your hostname.

  hardware.apple-t2.enableAppleSetOsLoader = true;
  boot.kernelParams = [ "hid_apple.swap_opt_cmd=1" ];
}
