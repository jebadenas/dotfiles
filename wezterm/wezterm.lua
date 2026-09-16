local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 15
config.line_height = 1.15 -- airier vertical spacing between lines
config.default_cursor_style = "SteadyBar" -- slim bar cursor (lighter, more modern)
config.window_decorations = "RESIZE"

-- AeroSpace tiles windows to exact pixel sizes. use_resize_increments=false lets
-- WezTerm fill the exact size so there are no unpainted "black bar" strips.
-- Interior padding is painted with the background color, so it's safe to add for
-- some breathing room (if black edges ever return, set padding back to 0).
config.use_resize_increments = false
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }

-- herdr manages tabs/workspaces itself, so WezTerm's own tab bar is redundant.
config.enable_tab_bar = false

-- Make the left Option key a real Alt/Meta modifier (instead of typing accented
-- characters) so alt+ keybindings reach herdr. Right Option still composes.
config.send_composed_key_when_left_alt_is_pressed = false

-- Master color palette: everything inside WezTerm (shell, nvim, Claude Code)
-- inherits these 16 colors.
config.color_scheme = "Catppuccin Latte"

-- Keep the cursor visible against the light background.
config.colors = {
	cursor_bg = "#4c4f69",
	cursor_border = "#4c4f69",
	cursor_fg = "#eff1f5",
}

return config
