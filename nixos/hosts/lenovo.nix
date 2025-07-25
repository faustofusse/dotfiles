{ config, pkgs, ... } @ inputs :

{
  imports = [
    ../hardware/lenovo.nix
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hostName = "faulenovo"; # Define your hostname.
}
