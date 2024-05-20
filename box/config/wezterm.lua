local wezterm = require 'wezterm'
local act = wezterm.action

-- Simplified version of nightfox theme that skips tab bar stuff.
-- https://github.com/EdenEast/nightfox.nvim/blob/main/extra/nightfox/wezterm.toml
local colors = {
    foreground = "#cdcecf",
    background = "#192330",
    cursor_bg = "#cdcecf",
    cursor_border = "#cdcecf",
    cursor_fg = "#192330",
    compose_cursor = '#f4a261',
    selection_bg = "#2b3b51",
    selection_fg = "#cdcecf",
    scrollbar_thumb = "#71839b",
    split = "#131a24",
    visual_bell = "#cdcecf",
    ansi = {"#393b44", "#c94f6d", "#81b29a", "#dbc074", "#719cd6", "#9d79d6", "#63cdcf", "#dfdfe0"},
    brights = {"#575860", "#d16983", "#8ebaa4", "#e0c989", "#86abdc", "#baa1e2", "#7ad5d6", "#e4e4e5"},
    indexed = {
        [16] = "#d67ad2",
        [17] = "#f4a261",
    },
}

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
        -- Quadruple click to select command output
        {
            event = { Down = { streak = 4, button = 'Left' } },
            action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
            mods = 'NONE',
        },

        -- Change the default click behavior so that it only selects
        -- text and doesn't open hyperlinks
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'NONE',
            action = act.CompleteSelection 'ClipboardAndPrimarySelection',
        },
        -- and make CTRL-Click open hyperlinks
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = act.OpenLinkAtMouseCursor,
        },
    },
}
