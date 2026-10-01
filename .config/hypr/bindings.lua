-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Mac-style 한/영 key: Caps Lock (keycode 66) toggles fcitx5 Hangul input.
o.bind("code:66", "Toggle Korean input", "fcitx5-remote -t")

-- ---------------------------------------------------------------------------
-- macOS-style shortcuts. Cmd is SUPER here.
-- App shortcuts (Cmd+A/Z/S/F/T/N/W/R/L) are sent to the focused app as CTRL+key,
-- like Omarchy's universal copy/paste. In terminals, Cmd+T/N/W send kitty's
-- CTRL+SHIFT+key and the rest do nothing (CTRL+Z/S/R/L/A mean something else
-- in a shell).
-- ---------------------------------------------------------------------------
local function send_once(mods, key)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end
  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end
  return false
end

local function mac_shortcut(app_mods, key, terminal_mods)
  return function()
    if active_window_is_terminal() then
      if terminal_mods then
        send_once(terminal_mods, key)
      end
    else
      send_once(app_mods, key)
    end
  end
end

-- Free the SUPER keys that Omarchy uses for window management, and move those
-- actions to the Mac-equivalent or a nearby key.
hl.unbind("SUPER + F")          -- was: Full screen      -> now SUPER+CTRL+F
hl.unbind("SUPER + CTRL + F")   -- was: Tiled full screen -> now SUPER+SHIFT+CTRL+F
hl.unbind("SUPER + T")          -- was: Toggle floating  -> now SUPER+SHIFT+T
hl.unbind("SUPER + W")          -- was: Close window     -> SUPER+Q still closes
hl.unbind("SUPER + S")          -- was: Scratchpad       -> SUPER+` still toggles it
hl.unbind("SUPER + L")          -- was: Workspace layout -> now SUPER+SHIFT+L
hl.unbind("SUPER + TAB")        -- was: Next workspace
hl.unbind("SUPER + SHIFT + TAB") -- was: Previous workspace
hl.unbind("SUPER + SPACE")      -- was: Omarchy menu     -> now SUPER+ALT+SPACE
hl.unbind("SUPER + ALT + SPACE") -- was: Apps menu        -> now SUPER+SPACE
hl.unbind("SUPER + CTRL + Q")   -- was: Calculator (XF86Calculator still works)
hl.unbind("SUPER + SHIFT + code:12") -- was: Move window to workspace 3
hl.unbind("SUPER + SHIFT + code:13") -- was: Move window to workspace 4
hl.unbind("SUPER + SHIFT + code:14") -- was: Move window to workspace 5

-- Editing and app shortcuts.
o.bind("SUPER + A", "Select all", mac_shortcut("CTRL", "A"))
o.bind("SUPER + Z", "Undo", mac_shortcut("CTRL", "Z"))
o.bind("SUPER + SHIFT + Z", "Redo", mac_shortcut("CTRL SHIFT", "Z"))
o.bind("SUPER + S", "Save", mac_shortcut("CTRL", "S"))
o.bind("SUPER + F", "Find", mac_shortcut("CTRL", "F"))
o.bind("SUPER + R", "Reload", mac_shortcut("CTRL", "R"))
o.bind("SUPER + L", "Address bar", mac_shortcut("CTRL", "L"))
o.bind("SUPER + T", "New tab", mac_shortcut("CTRL", "T", "CTRL SHIFT"))
o.bind("SUPER + N", "New window", mac_shortcut("CTRL", "N", "CTRL SHIFT"))
o.bind("SUPER + W", "Close tab", mac_shortcut("CTRL", "W", "CTRL SHIFT"))

-- Window and system shortcuts.
o.bind("SUPER + CTRL + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + SHIFT + CTRL + F", "Tiled full screen", "omarchy-hyprland-window-tiled-fullscreen-toggle")
o.bind("SUPER + SHIFT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + SHIFT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.bind("SUPER + M", "Minimize (to scratchpad)", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
o.bind("SUPER + TAB", "Switch to next window", hl.dsp.window.cycle_next())
o.bind("SUPER + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
o.bind("SUPER + SHIFT + TAB", "Switch to previous window", hl.dsp.window.cycle_next({ next = false }))
o.bind("SUPER + SHIFT + TAB", "Reveal active window on top", hl.dsp.window.bring_to_top())
o.bind("SUPER + SPACE", "Apps menu (Spotlight)", "omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle")
o.bind("SUPER + CTRL + Q", "Lock system", "omarchy-system-lock")

-- Text navigation: Cmd+Left/Right = line start/end, Cmd+Up/Down = top/bottom.
-- In terminals, Cmd+Up/Down scroll kitty's scrollback to the top/bottom.
-- Window focus moves from SUPER+arrows to SUPER+ALT+arrows (which were
-- "Move window to group"; SUPER+G grouping still works).
for _, dir in ipairs({ "LEFT", "RIGHT", "UP", "DOWN" }) do
  hl.unbind("SUPER + " .. dir)
  hl.unbind("SUPER + ALT + " .. dir)
end
o.bind("SUPER + LEFT", "Line start", mac_shortcut("", "Home", ""))
o.bind("SUPER + RIGHT", "Line end", mac_shortcut("", "End", ""))
o.bind("SUPER + UP", "Document start", mac_shortcut("CTRL", "Home", "CTRL SHIFT"))
o.bind("SUPER + DOWN", "Document end", mac_shortcut("CTRL", "End", "CTRL SHIFT"))
o.bind("SUPER + ALT + LEFT", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + ALT + RIGHT", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + ALT + UP", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + ALT + DOWN", "Focus on below window", hl.dsp.focus({ direction = "d" }))

-- Screenshots: Cmd+Shift+3 full screen, Cmd+Shift+4 region, Cmd+Shift+5 capture menu.
o.bind("SUPER + SHIFT + code:12", "Screenshot Display", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + code:13", "Screenshot Region", "omarchy-capture-screenshot region")
o.bind("SUPER + SHIFT + code:14", "Capture menu", "omarchy-menu toggle capture")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
