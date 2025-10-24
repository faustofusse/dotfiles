# iso

Crear el ISO

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```

Formatear un USB

```bash
sudo dd bs=4M status=progress if=result/iso/nixos-minimal-25.11.20251019.5e2a59a-x86_64-linux.iso of=/dev/sda
```

Todo junto

```bash
sudo su && nix build .#nixosConfigurations.iso.config.system.build.isoImage && dd bs=4M status=progress if=result/iso/nixos-minimal-25.11.20251019.5e2a59a-x86_64-linux.iso of=/dev/sda
```

Para ver los logs del script de activacion (dentro del ISO)

```bash
journalctl --user --unit=nixos-activation.service
```

Para correr el ISO en un emulador

```bash
qemu-system-x86_64 -enable-kvm -m 256 -cdrom result/iso/nixos-minimal-25.11.20251019.5e2a59a-x86_64-linux.iso
```
