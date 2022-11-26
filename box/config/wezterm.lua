local wezterm = require 'wezterm'
local act = wezterm.action

local color_scheme = 'Solarized Dark (base16)'
local colors = wezterm.color.get_builtin_schemes()[color_scheme]
colors.scrollbar_thumb = colors.cursor_fg

return {
    adjust_window_size_when_changing_font_size = false, -- using a tiling window manager
    audible_bell = 'Disabled',
    automatically_reload_config = true,
    check_for_updates = false,
    colors = colors,
    enable_scroll_bar = true,
    font = wezterm.font 'Monospace',
    font_size = 10.0,
    force_reverse_video_cursor = true,
    hide_tab_bar_if_only_one_tab = true,
    pane_focus_follows_mouse = true,
    scrollback_lines = 10000,
    selection_word_boundary = ' \t\n{}[]()"\'`,;:',

    -- Would like to enable this but breaks SSH'ing into machines that don't
    -- have this terminfo.
    -- term = 'wezterm',

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
