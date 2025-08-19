#!/bin/bash

# si se desmountea, hacer lo siguiente
#
# diskutil list
# diskutil info disk3s7 | grep 'Volume UUID'
# sudo vifs
# UUID=FEFE2882-A7A9-408B-8C69-57B04F7CBF07 /nix apfs rw,nobrowse,suid,owners
# reboot

sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo launchctl kickstart -k system/org.nixos.nix-daemon
