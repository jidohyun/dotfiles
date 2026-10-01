-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- hl.config({
--   input = {
--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
--     kb_layout = "us,dk,eu",
--     kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",
--
--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
--     kb_variant = "intl",
--
--     -- Change speed of keyboard repeat.
--     repeat_rate = 40,
--     repeat_delay = 250,
--
--     -- Start with numlock on by default.
--     numlock_by_default = true,
--
--     -- Increase sensitivity for mouse/trackpad (default: 0).
--     sensitivity = 0.35,
--
--     -- Turn off mouse acceleration (default: adaptive).
--     accel_profile = "flat",
--
--     touchpad = {
--       -- Use traditional (non-inverse) scrolling.
--       natural_scroll = false,
--
--       -- Re-enable tap-to-click (one-finger tap = left, two-finger = right).
--       tap_to_click = true,
--
--       -- Use two-finger clicks for right-click instead of lower-right corner.
--       clickfinger_behavior = true,
--
--       -- Control the speed of your scrolling.
--       scroll_factor = 0.4,
--
--       -- Enable the touchpad while typing.
--       disable_while_typing = false,
--
--       -- Left-click-and-drag with three fingers.
--       drag_3fg = 1,
--     },
--   },
-- })

-- Mac-style 한/영 key: Caps Lock toggles Hangul (see bindings.lua).
-- Caps Lock's own function and compose are disabled; both Shifts still set Caps Lock.
hl.config({
  input = {
    kb_options = "caps:none,shift:both_capslock_cancel",

    -- Faster key repeat.
    repeat_rate = 40,
    repeat_delay = 250,

    touchpad = {
      -- macOS-style: natural scrolling, two-finger click = right click.
      natural_scroll = true,
      clickfinger_behavior = true,
    },
  },
})

-- macOS-style trackpad gestures (three-finger drag must stay off, or libinput
-- turns three-finger motion into a mouse drag before Hyprland sees a swipe).
-- Three fingers left/right: switch workspace (Spaces).
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
-- Three fingers up: Mission Control-style overview of every window.
hl.gesture({ fingers = 3, direction = "up", action = function()
  hl.dispatch(hl.dsp.exec_cmd("omarchy-shell -q shell toggle io.github.proof001.window-overview"))
end })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
