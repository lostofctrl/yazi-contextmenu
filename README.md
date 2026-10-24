# contextmenu.yazi

Small clickable context menu near the cursor (like a file explorer).

- Right-click a file, or middle-click it, to open the menu there.
- Click an item to run it; click elsewhere or scroll to dismiss.
- Hover highlight needs `move` events (yazi.toml):

      [mgr]
      mouse_events = ["click", "scroll", "touch", "move"]

- Keyboard fallback (keymap.toml): `{ on = "<F2>", run = "plugin contextmenu", desc = "Context menu" }`

Install: copy `contextmenu.yazi` to `~/.config/yazi/plugins/` and add
`require("contextmenu"):setup()` to `~/.config/yazi/init.lua`.

Ctrl+click is not possible: Yazi's Lua mouse event exposes no modifier keys.
