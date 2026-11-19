# SkullOS

A bootable, macOS-style Linux (Debian 12 + GNOME + WhiteSur theme) with Claude Code, Chrome,
offline voice, encrypted S3 snapshots, and opt-in compute sharing. It runs from a USB stick, can be
installed to disk, or runs as a cloud desktop on Modal.

| Feature | How |
|---|---|
| Mac-like desktop | WhiteSur GTK/icons/cursors, bottom dock (dash-to-dock), window buttons on the left, Inter font |
| Claude + Chrome | Claude Code (`claude`) and Google Chrome come preinstalled. Sign in on first boot from the Welcome app |
| Voice | **Super+Space**: whisper.cpp speech-to-text, then `claude -p`, then Piper text-to-speech (all offline except Claude) |
| Sync & snapshots | `skull-setup`, then hourly encrypted restic snapshots of `$HOME` to any S3. `skull-sync restore` on any machine |
| Observe | `skull-observe` saves machine state as JSON with every snapshot |
| Compute sharing | `skull-mesh up/host/join`: Tailscale + Ray, opt-in, capped at half your CPU/RAM by default |
| USB persistence | `skull-persist` (or `scripts/make-usb.sh` on Linux) |
| Cloud | `cloud/` is a noVNC desktop. Deploy with `modal deploy cloud/modal_app.py` |

## Get the ISO
GitHub Actions builds it and boot-tests it in QEMU (**Actions → Build ISO → artifacts**). Pushing a
`v*` tag publishes it to Releases. To build locally on an x86_64 machine with Docker, run `./iso/build.sh`.

## Write it to USB
`./scripts/make-usb.sh skullos-amd64.hybrid.iso /dev/diskN` (macOS/Linux), or use balenaEtcher.
The live user is `skull` and the password is `live`.

## Notes
- No credentials are baked in. Your Claude/Chrome logins live in `$HOME`, which skull-sync encrypts and restores.
- Modal runs containers, not ISOs, so the cloud version is the same tools on XFCE instead of GNOME.
- This is not affiliated with Apple. The theme is the open-source WhiteSur project, fetched at build time.
