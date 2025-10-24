# iso

nix build .#nixosConfigurations.iso.config.system.build.isoImage
ls result/iso
ls /dev/sda*
sudo dd bs=4M status=progress if=result/iso/nixos-minimal-25.11.20251019.5e2a59a-x86_64-linux.iso of=/dev/sda
journalctl --user --unit=nixos-activation.service
qemu-system-x86_64 -enable-kvm -m 256 -cdrom result/iso/nixos-minimal-25.11.20251019.5e2a59a-x86_64-linux.iso
