#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  true)
    scheme=prefer-dark
    theme_name='Default Dark Modern'
    kitty_theme=dark
    ;;
  false)
    scheme=prefer-light
    theme_name='Default Light Modern'
    kitty_theme=light
    ;;
  *)
    printf 'usage: %s true|false\n' "$0" >&2
    exit 2
    ;;
esac

if ! gsettings set org.gnome.desktop.interface color-scheme "$scheme"; then
  dconf write /org/gnome/desktop/interface/color-scheme "'$scheme'"
fi
jq ". + {\"workbench.colorTheme\": \"$theme_name\"}" "$HOME/.config/Code/User/settings.json" > tmp.$$.json && mv tmp.$$.json "$HOME/.config/Code/User/settings.json"

kitty_conf="$HOME/.config/kitty/_$kitty_theme.conf"
ln -sfn "_$kitty_theme.conf" "$HOME/.config/kitty/theme.conf"
for sock in /tmp/kitty-*; do
  [ -S "$sock" ] || continue
  kitten @ --to "unix:$sock" set-colors --all --configured "$kitty_conf" || true
done
