# creacion del iso

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

# instalacion (desde iso) borrando todo lo que habia

Verificar UEFI:

```bash
test -d /sys/firmware/efi && echo UEFI || echo Legacy
```

Inspeccionar discos:

```bash
lsblk -o NAME,SIZE,FSTYPE,PARTLABEL,TYPE,MOUNTPOINTS
```

Abrir TUI con el disco a pisar $disk (ejemplos: /dev/nvme0n1 o /dev/sda):

```bash
cfdisk $disk
```

Wipe signatures (optional):

```bash
wipefs -a $disk
```


Perfect—here’s a clean, full-disk UEFI layout with swap using
parted.

Danger: This erases the selected disk.

• Set variables
 • DISK=/dev/nvme0n1  (or /dev/sda)
 • SWAP_GIB=16        (adjust as desired; ≥ RAM for hibernate)
 • SWAP_END=$((513 + SWAP_GIB*1024))  # MiB end of swap
• Partition (UEFI GPT)
 • parted -s "$DISK" mklabel gpt
 • parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
 • parted -s "$DISK" set 1 esp on
 • parted -s "$DISK" mkpart swap linux-swap 513MiB
 ${SWAP_END}MiB
 • parted -s "$DISK" mkpart primary ext4 ${SWAP_END}MiB 100%
 • Verify: parted -s "$DISK" print
• Format
 • ESP: mkfs.vfat -F32 -n EFI ${DISK}p1  (use ${DISK}1 on SATA)
 • Swap: mkswap -L swap ${DISK}p2
 • Root: mkfs.ext4 -L nixos ${DISK}p3
• Mount
 • Root: mount /dev/disk/by-label/nixos /mnt
 • ESP: mkdir -p /mnt/boot && mount /dev/disk/by-label/EFI
 /mnt/boot
 • Enable swap: swapon /dev/disk/by-label/swap



Generate hardware config

• nixos-generate-config --root /mnt
• Verify swap is listed in
/mnt/etc/nixos/hardware-configuration.nix; if not, ensure swap
is on and rerun.

Use your flake (copy from ISO)

• mkdir -p /mnt/etc/nixos
• cp -a /etc/dotfiles/nixos/. /mnt/etc/nixos/

Pick a host target

• Available: #fauhp, #faumbp, #faulenovo
• Overwrite that host’s hardware file with the generated one:
 • For example, using hp: cp
 /mnt/etc/nixos/hardware-configuration.nix
 /mnt/etc/nixos/hardware/hp.nix


chmod -R u+w /mnt/etc/nixos


• export NIX_CONFIG='experimental-features = nix-command
flakes'
• nixos-install --root /mnt --flake /mnt/etc/nixos#fauhp  (or
your chosen host)



# con minimal installer

sudo su
ip link show # busco la wifi interface -> ejemplo: wlp0s20f3
wpa_passphrase "Personal Wifi 5.8GHz" > wifi.conf
wpa_supplicant -i $interface -c wifi.conf -B
ping nixos.org
mkdir -p /mnt/boot
mount /dev/disk/by-label/nixos /mnt
mount /dev/disk/by-label/EFI /mnt/boot
swapon /dev/disk/by-label/swap
mkdir -p /mnt/home/fausto
git clone https://github.com/faustofusse/dotfiles /mnt/home/fausto/.dotfiles
nixos-generate-config --root /mnt
cd /mnt/home/fausto/.dotfiles/nixos
cp /mnt/etc/nixos/hardware-configuration.nix ./hardware/$host.nix
vim ./hosts/$host.nix # creo archivo para host. copiar uno y editarlo
vim ./flake.nix # agrego host
git add .
export NIX_CONFIG='experimental-features = nix-command flakes'
nixos-install --root /mnt --flake .#$host
chown -R nixos:users /mnt/home/fausto/.dotfiles
reboot
