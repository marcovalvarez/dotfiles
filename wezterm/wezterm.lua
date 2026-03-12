local wezterm = require("wezterm")

return {
        font = wezterm.font("JetBrainsMono Nerd Font"),
        font_size = 14,

        window_background_opacity = 0.95,
        macos_window_background_blur = 20,

        color_scheme = "Catppuccin Mocha",

        hide_tab_bar_if_only_one_tab = true,

        keys = {
                { key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
                { key = "c", mods = "CMD", action = wezterm.action.CopyTo("Clipboard") },
        },
}
