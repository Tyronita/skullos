#!/usr/bin/env bash
# Start the SkullOS cloud desktop: VNC + noVNC on :6080, optional S3 restore and periodic snapshots.
# Env: VNC_PASSWORD (required), SKULL_S3_BUCKET/REGION/ENDPOINT, AWS_ACCESS_KEY_ID,
#      AWS_SECRET_ACCESS_KEY, RESTIC_PASSWORD, SKULL_AUTO_RESTORE=1, SKULL_SNAPSHOT_MINUTES=30
set -euo pipefail
U=skull; H=/home/$U
: "${VNC_PASSWORD:?set VNC_PASSWORD}"
mkdir -p "$H"
# Fresh volume? seed from skel
[ -f "$H/.bashrc" ] || cp -rT /etc/skel "$H"
chown -R $U:$U "$H"
as() { runuser -u $U -- env HOME=$H "$@"; }

if [ -n "${SKULL_S3_BUCKET:-}" ] && [ -n "${RESTIC_PASSWORD:-}" ]; then
  as mkdir -p "$H/.config/skull"
  ( umask 077
    for v in SKULL_S3_BUCKET SKULL_S3_REGION SKULL_S3_ENDPOINT SKULL_S3_PREFIX AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY RESTIC_PASSWORD SKULL_MACHINE_NAME; do
      [ -n "${!v:-}" ] && printf '%s=%q\n' "$v" "${!v}"
    done > "$H/.config/skull/sync.env" )
  chown $U:$U "$H/.config/skull/sync.env"
  as bash -c 'restic_repo_ok=1; skull-sync list >/dev/null 2>&1 || (
      . ~/.config/skull/sync.env
      export RESTIC_REPOSITORY="s3:${SKULL_S3_ENDPOINT:-s3.amazonaws.com}/$SKULL_S3_BUCKET/${SKULL_S3_PREFIX:-skullos}" RESTIC_PASSWORD AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
      restic init )' || echo "WARN: could not reach S3 repo"
  if [ "${SKULL_AUTO_RESTORE:-0}" = 1 ] && [ ! -f "$H/.config/skull/restored" ]; then
    as skull-sync restore && as touch "$H/.config/skull/restored" || echo "WARN: restore failed"
  fi
  # periodic snapshots
  ( while sleep $(( ${SKULL_SNAPSHOT_MINUTES:-30} * 60 )); do as skull-sync snapshot || true; done ) &
  trap 'echo "final snapshot…"; as skull-sync snapshot || true; exit 0' TERM INT
fi

as mkdir -p "$H/.vnc"
printf '%s\n' "$VNC_PASSWORD" | as vncpasswd -f > "$H/.vnc/passwd"; chown $U:$U "$H/.vnc/passwd"; chmod 600 "$H/.vnc/passwd"
printf '#!/bin/sh\nskull-desktop-init &\nexec dbus-launch --exit-with-session startxfce4\n' > "$H/.vnc/xstartup"
chmod +x "$H/.vnc/xstartup"; chown $U:$U "$H/.vnc/xstartup"
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
as vncserver :1 -geometry "${SKULL_GEOMETRY:-1600x1000}" -depth 24 -localhost yes -SecurityTypes VncAuth \
   -rfbauth "$H/.vnc/passwd" -xstartup "$H/.vnc/xstartup"
websockify --web /usr/share/novnc 0.0.0.0:6080 localhost:5901 &
echo "SkullOS Cloud desktop ready on :6080"
wait
