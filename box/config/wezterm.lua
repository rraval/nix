local wezterm = require 'wezterm'
local act = wezterm.action

return {
    adjust_window_size_when_changing_font_size = false, -- using a tiling window manager
    audible_bell = 'Disabled',
    automatically_reload_config = true,
    check_for_updates = false,
    color_scheme = 'Solarized Dark Higher Contrast',
    enable_scroll_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    pane_focus_follows_mouse = true,
    scrollback_lines = 10000,
    term = 'wezterm',

    keys = {
        { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollToPrompt(-1) },
        { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollToPrompt(1) },
    },

    mouse_bindings = {
        {
            event = { Down = { streak = 4, button = 'Left' } },
            action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
            mods = 'NONE',
        },
    },
}