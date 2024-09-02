{ config, pkgs, ... } @ inputs :

{
  imports = [
    ../hardware/hp.nix
    inputs.xremap-flake.nixosModules.default
    inputs.nixos-hardware.nixosModules.apple-t2
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hostName = "fauhp"; # Define your hostname.
}
