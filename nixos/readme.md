# iso

nix build .#nixosConfigurations.live.config.system.build.isoImage
ls result/iso
ls /dev/sda*
sudo dd bs=4M status=progress if=result/iso/nixos-minimal-25.11.20251019.5e2a59a-x86_64-linux.iso of=/dev/sda
