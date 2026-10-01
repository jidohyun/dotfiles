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

Moonlight client: 1920x1200, 60 fps, 20 Mbps, H.264, capture system keys in fullscreen.
Right Option is no longer an fcitx5 trigger key, so Moonlight can use it as Cmd on a Mac host.
