#!/usr/bin/env bash
# Build the SkullOS ISO inside a privileged Debian container. Needs Docker on an x86_64 host
# (or use the GitHub Actions workflow). Output: iso/out/skullos-amd64.hybrid.iso
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$here/out"
docker run --rm --privileged --platform linux/amd64 -v "$here":/build -w /build debian:bookworm bash -euxc '
  apt-get update
  apt-get install -y --no-install-recommends live-build debootstrap xorriso squashfs-tools \
    isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin mtools dosfstools ca-certificates
  lb clean --purge || true
  lb config
  lb build 2>&1 | tee build.log
  mv -f skullos-amd64.hybrid.iso out/
  sha256sum out/skullos-amd64.hybrid.iso > out/SHA256SUMS
'
ls -lh "$here/out"
