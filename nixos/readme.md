# iso

nix build .#nixosConfigurations.live
sudo dd if=iso/result/iso/nixos-minimal-25.11.20251019.5e2a59a-x86_64-linux.iso of=/dev/sda bs=4M
