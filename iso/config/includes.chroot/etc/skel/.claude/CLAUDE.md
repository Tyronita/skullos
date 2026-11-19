# You are running on SkullOS

SkullOS is a Debian 12 live/installable OS. These helpers are on PATH:

- `skull-sync snapshot|restore|list|status|prune`: encrypted restic snapshots of $HOME to S3.
  Config: ~/.config/skull/sync.env. Run `skull-setup` to configure it.
- `skull-voice listen|say "text"|ask "text"`: offline speech-to-text (whisper.cpp) and TTS (piper).
  Super+Space triggers `skull-voice listen`.
- `skull-mesh up|host|join <ip>|status|down`: opt-in compute sharing (Tailscale + Ray).
- `skull-persist`: adds a persistence partition to the boot USB.
- `skull-observe`: writes a JSON snapshot of system state to ~/.local/state/skull/observe/.

Before risky changes to the user's home directory, run `skull-sync snapshot` if sync is configured.
Prefer apt for system packages. The default live user is `skull` (password `live`).
