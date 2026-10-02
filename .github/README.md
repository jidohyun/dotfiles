# dotfiles

Omarchy (Mac fork, Asahi Linux) on a MacBook Pro M1 — personal overrides only.
Omarchy's defaults live in /usr/share/omarchy and are not tracked here.

## What's here

| Path | What |
|---|---|
| .config/hypr/ | Hyprland overrides: macOS-style shortcuts (bindings.lua), trackpad + gestures (input.lua) |
| .config/omarchy/shell.json | Bar layout, idle, enabled shell plugins |
| .config/omarchy/themes/rose-pine-dark/ | Custom dark Rose Pine theme |
| .config/kitty/kitty.conf | kitty terminal |
| .config/xdg-terminals.list | Default terminal = kitty |
| .config/git/config | git settings |

## Managing

The repo is a bare git repo in ~/.dotfiles with $HOME as the work tree:

    alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    dot status
    dot add ~/.config/some/file
    dot commit -m "..."
    dot push

## Restoring on a fresh Omarchy install

    git clone --bare https://github.com/jidohyun/dotfiles.git ~/.dotfiles
    alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    dot checkout          # move conflicting default files aside first if it complains
    dot config status.showUntrackedFiles no

Then the parts that are not plain files:

    omarchy install terminal kitty
    omarchy theme install https://github.com/vyrx-dev/omarchy-aamis-theme.git   # current theme
    # alternative kept in this repo: omarchy theme set rose-pine-dark
    omarchy toggle idle stay-awake
    omarchy plugin add https://github.com/proof001/omarchy-window-overview.git --enable --yes   # App Expose (3 fingers down, Ctrl+Down)
    omarchy plugin add https://github.com/zzwong/omarchy-stage.git --enable --yes                # Mission Control (3 fingers up, Ctrl+Up)
    omarchy plugin add https://github.com/Shavanced/omarchy-notification-center-plugin.git --enable --yes
    omarchy plugin add https://github.com/GreyforgeLabs/reprieve.git --enable --yes
    omarchy plugin add https://github.com/rosakodu/omarchy-dock.git --enable --yes
    omarchy plugin add https://github.com/GreyforgeLabs/omarchy-hotbar.git --yes && ~/.config/omarchy/plugins/greyforge.hotbar/bin/hotbar install
    omarchy plugin add https://github.com/thisisgm/omarchy-pods.git --enable --yes && ~/.config/omarchy/plugins/io.github.thisisgm.omapods/setup
    # AI Usage: the AUR release signature key is not on public keyservers; checksum still verified
    git clone https://aur.archlinux.org/ai-usagebar-bin.git /tmp/aub && (cd /tmp/aub && makepkg -si --skippgpcheck)
    omarchy plugin add https://github.com/akitaonrails/ai-usagebar.git --enable --yes
    hyprctl reload && hyprctl configerrors

## Remote desktop (both ways, over Tailscale)

This laptop is a Sunshine host (software x264; Asahi has no HW encoder) and a
Moonlight client. Sunshine config is tracked (`.config/sunshine/sunshine.conf`);
its credentials/state and Moonlight.conf (holds the pairing key) are not.

    # sunshine lives in [omarchy], which pacman.conf marks Usage = Sync, so fetch + verify + -U
    f=$(tar -xOf /var/lib/pacman/sync/omarchy.db --wildcards 'sunshine-*/desc' | awk '/%FILENAME%/{getline;print}')
    curl -LO https://pkgs.omarchy.org/edge/aarch64/$f -LO https://pkgs.omarchy.org/edge/aarch64/$f.sig
    pacman-key --verify $f.sig $f && sudo pacman -U $f
    sudo ufw allow in on tailscale0 proto tcp to any port 47984,47989,48010
    sudo ufw allow in on tailscale0 proto udp to any port 47998:48000
    sunshine --creds sunshine '<password>'
    systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service

Moonlight client (to the Mac): 1728x1080 (exact half of the 3456-wide panel), 60 fps, 12 Mbps,
HEVC, software decoding, packet size 1024, frame pacing off, V-Sync off, capture system keys in
fullscreen. Launched pinned to the P-cores (`taskset -c 2-9`, cpu0-1 are E-cores) via
`.local/share/applications/com.moonlight_stream.Moonlight.desktop`. Measured: decode ~5 ms, 0 errors.
Mac -> this laptop: the Mac's personal tailnet is a userspace tailscaled (the Tailscale app is on a
company tailnet), so Mac apps reach this laptop only through its SOCKS5 proxy (127.0.0.1:1055).
`.config/sunshine/mac-relay/moonlight-socks-relay.py` runs on the Mac as LaunchAgent
`com.m1omarchy.moonlight-socks-relay`, listening on 127.0.0.1 TCP 48984/48989/49010 and UDP
48998-49000 and forwarding via SOCKS5 CONNECT / UDP ASSOCIATE. This laptop's Sunshine uses
port base 48989 (the Mac's own Sunshine owns the defaults), `capture = kms` (wlr capped at ~24 fps;
the binary already has cap_sys_admin) and `min_threads = 8`. Mac Moonlight: host 127.0.0.1:48989,
1728x1080@60, H.264, 8 Mbps (15 Mbps overloads the relay path: 25% loss), packet size 1024,
remote-desktop mouse mode (KMS has no cursor plane). Measured: 57.6 fps, 2.3% loss.

Mac host side (2026-10-02, measured from here): Sunshine 2026.914 on default ports, no relay,
vt_realtime = disabled (enabled caused ~32 IDR waits/25 s), fec_percentage = 10. The Mac is on
Wi-Fi; turning AWDL off (`sudo ifconfig awdl0 down`, resets on reboot) cut stream jitter from
±11-21 ms to ±1 ms and jitter drops from 7-8% to 0.8%.
Tried 2026-10-02: omarchy-m1-video patched apple_avd (patches 029f57377a00) on this M1 Pro (t6000).
HEVC HW decode still hit "H0 error" / "Frame processing timed out" and H.264 HW still re-requested
IDRs, so it was uninstalled and the stock module + distro libva-v4l2_request-avd restored.
- packetsize 1024: Tailscale MTU is 1280; bigger video packets fragment and ~7% of frames were lost.
- HEVC: the Mac's VideoToolbox H.264 declares 1 reference frame but uses 2, so frames corrupt.
- software decode: the Asahi AVD HEVC hardware path (v4l2-request) stalls with a black screen.
Right Option is no longer an fcitx5 trigger key, so Moonlight can use it as Cmd on a Mac host.
