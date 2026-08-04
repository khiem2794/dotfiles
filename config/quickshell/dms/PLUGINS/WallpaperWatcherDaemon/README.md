# Wallpaper Watcher Daemon

Run a script whenever your wallpaper changes.

## What it does

This daemon monitors wallpaper changes and executes a script you specify. The new wallpaper path gets passed as the first argument to your script.

## Setup

1. Enable the plugin in Settings → Plugins
2. Configure the script path in the plugin settings
3. Make sure your script is executable (`chmod +x /path/to/script.sh`)

## Example script

```bash
#!/bin/bash
echo "New wallpaper: $1"
# Do something with the wallpaper path
```

Save this to a file, make it executable, and point the plugin to it.

## Use cases

- Generate color schemes from the new wallpaper
- Update theme files based on wallpaper colors
- Send notifications when wallpaper changes
- Sync wallpaper info to other devices
- Log wallpaper history

## Notes

- Script errors show up as toast notifications
- Script output goes to console logs
- The daemon runs invisibly in the background
