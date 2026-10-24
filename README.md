# yazi-contextmenu

A small, clickable context menu for [Yazi](https://github.com/sxyazi/yazi),
shown next to the cursor like in a desktop file explorer. It also adds
double-click to open.

## Features
- **Right-click** or **middle-click** a file to open the menu at the cursor.
- Click an item to run it. Click elsewhere or scroll to dismiss.
- Actions: open, open with, rename, copy, cut, paste, new file/dir, copy path,
  copy filename, toggle selection, trash, delete permanently.
- **Double-click** a file or folder to open/enter it.
- Hover highlight on the item under the pointer.

Ctrl+click is not supported: Yazi's Lua mouse event exposes no modifier keys.

## Install
```sh
ya pkg add lostofctrl/yazi-contextmenu:contextmenu
```

Add to `~/.config/yazi/init.lua`:
```lua
require("contextmenu"):setup()
```

Enable mouse move events (hover highlight) in `~/.config/yazi/yazi.toml`:
```toml
[mgr]
mouse_events = ["click", "scroll", "touch", "move"]
```

Optional keyboard fallback, in `keymap.toml`:
```toml
[[mgr.prepend_keymap]]
on   = "<F2>"
run  = "plugin contextmenu"
desc = "Context menu"
```

Requires Yazi 25.2.7 or newer (tested on 26.9.1).

## Update / remove
```sh
ya pkg upgrade
ya pkg delete lostofctrl/yazi-contextmenu:contextmenu
```

## License
MIT
