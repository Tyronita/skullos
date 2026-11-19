#!/usr/bin/env bash
# Write the SkullOS ISO to a USB stick (macOS or Linux). ERASES THE TARGET DEVICE.
#   ./scripts/make-usb.sh skullos-amd64.hybrid.iso /dev/sdX        (Linux)
#   ./scripts/make-usb.sh skullos-amd64.hybrid.iso /dev/disk4      (macOS, see `diskutil list`)
# Linux also gets a persistence partition. On macOS, boot the stick and run "skull-persist".
set -euo pipefail
iso=${1:?iso path}; dev=${2:?device}
[ -f "$iso" ] || { echo "No such ISO: $iso" >&2; exit 1; }
echo "About to ERASE $dev and write $iso"
if [ "$(uname)" = Darwin ]; then diskutil list "$dev"; else lsblk "$dev"; fi
read -rp "Type the device path again to confirm: " again; [ "$again" = "$dev" ] || exit 1

if [ "$(uname)" = Darwin ]; then
  diskutil unmountDisk "$dev"
  sudo dd if="$iso" of="${dev/disk/rdisk}" bs=4m status=progress
  sync; diskutil eject "$dev"
  echo "Done. Boot it, then run 'skull-persist' (or use the Welcome app) to keep changes."
  exit 0
fi

for p in "$dev"?*; do sudo umount "$p" 2>/dev/null || true; done
sudo dd if="$iso" of="$dev" bs=4M status=progress conv=fsync
echo ',,L' | sudo sfdisk --append --no-reread --force "$dev"
sudo partprobe "$dev" || sudo partx -u "$dev"; sleep 2
part=$(lsblk -lnpo NAME,TYPE "$dev" | awk '$2=="part"{p=$1} END{print p}')
sudo mkfs.ext4 -F -L persistence "$part"
mnt=$(mktemp -d); sudo mount "$part" "$mnt"
echo "/ union" | sudo tee "$mnt/persistence.conf" >/dev/null
sudo umount "$mnt"; rmdir "$mnt"; sync
echo "Done. USB with persistence ready."
