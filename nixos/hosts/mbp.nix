{ config, pkgs, ... } @ inputs :

{
  imports = [
    ../hardware/mbp.nix
    inputs.nixos-hardware.nixosModules.apple-t2
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hostName = "faumbp"; # Define your hostname.

  hardware.apple-t2.enableAppleSetOsLoader = true;
  boot.kernelParams = [ "hid_apple.swap_opt_cmd=1" ];
}
