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
-- fcitx5-remote -c switches to English first, so menu searches never start in Hangul.
o.bind("SUPER + SPACE", "Apps menu (Spotlight)", "fcitx5-remote -c; omarchy-menu toggle apps")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "fcitx5-remote -c; omarchy-menu toggle")
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

-- Option (ALT) text editing, macOS-style:
--   Option+Left/Right        word back/forward
--   Option+Shift+Left/Right  select by word
--   Option+Backspace         delete previous word
-- In terminals, word moves send readline's Alt+B/Alt+F and Option+Backspace
-- passes through as Alt+Backspace (both already mean "word" in a shell).
-- This takes over Alt+Left/Right, which Linux browsers use for back/forward,
-- so Cmd+[ / Cmd+] become back/forward like on macOS.
local function option_word(app_mods, app_key, terminal_mods, terminal_key)
  return function()
    if active_window_is_terminal() then
      if terminal_mods then
        send_once(terminal_mods, terminal_key)
      end
    else
      send_once(app_mods, app_key)
    end
  end
end
o.bind("ALT + LEFT", "Word back", option_word("CTRL", "Left", "ALT", "b"))
o.bind("ALT + RIGHT", "Word forward", option_word("CTRL", "Right", "ALT", "f"))
o.bind("ALT + SHIFT + LEFT", "Select word back", option_word("CTRL SHIFT", "Left"))
o.bind("ALT + SHIFT + RIGHT", "Select word forward", option_word("CTRL SHIFT", "Right"))
o.bind("ALT + BACKSPACE", "Delete word", option_word("CTRL", "BackSpace", "ALT", "BackSpace"))
-- Cmd+Backspace: delete to the start of the line. Apps get Shift+Home then
-- Backspace; terminals get Ctrl+U (readline's kill-to-line-start).
-- Window transparency toggle moves from SUPER+BACKSPACE to SUPER+ALT+BACKSPACE.
hl.unbind("SUPER + BACKSPACE")
o.bind("SUPER + ALT + BACKSPACE", "Toggle window transparency", "omarchy-hyprland-window-transparency-toggle")
o.bind("SUPER + BACKSPACE", "Delete to line start", function()
  if active_window_is_terminal() then
    send_once("CTRL", "U")
  else
    send_once("SHIFT", "Home")
    hl.timer(function()
      send_once("", "BackSpace")
    end, { timeout = 80, type = "oneshot" })
  end
end)
-- Ctrl+Up = Mission Control (Stage), Ctrl+Down = App Expose (window overview).
o.bind("CTRL + UP", "Mission Control", "omarchy-shell -q shell toggle zzwong.stage")
o.bind("CTRL + DOWN", "App Expose", "omarchy-shell -q shell toggle io.github.proof001.window-overview")
o.bind("SUPER + bracketleft", "Back", mac_shortcut("ALT", "Left"))
o.bind("SUPER + bracketright", "Forward", mac_shortcut("ALT", "Right"))

-- Screenshots: Cmd+Shift+3 full screen, Cmd+Shift+4 region, Cmd+Shift+5 capture menu.
o.bind("SUPER + SHIFT + code:12", "Screenshot Display", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + code:13", "Screenshot Region", "omarchy-capture-screenshot region")
o.bind("SUPER + SHIFT + code:14", "Capture menu", "omarchy-menu toggle capture")

-- Removed web apps; drop their shortcuts too.
hl.unbind("SUPER + SHIFT + Y")          -- YouTube
hl.unbind("SUPER + SHIFT + P")          -- Google Photos
hl.unbind("SUPER + SHIFT + S")          -- Google Maps
hl.unbind("SUPER + SHIFT + X")          -- X
hl.unbind("SUPER + SHIFT + ALT + X")    -- X Post
hl.unbind("SUPER + SHIFT + ALT + G")    -- WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G")   -- Google Messages

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
