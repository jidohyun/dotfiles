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
    omarchy theme set rose-pine-dark
    omarchy toggle idle stay-awake
    omarchy plugin add https://github.com/proof001/omarchy-window-overview.git --enable --yes
    hyprctl reload && hyprctl configerrors
