#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  true)
    scheme=prefer-dark
    theme_name='Default Dark Modern'
    ;;
  false)
    scheme=prefer-light
    theme_name='Default Light Modern'
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
