local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 15
config.window_decorations = "RESIZE"

-- herdr manages tabs/workspaces itself, so WezTerm's own tab bar is redundant.
config.enable_tab_bar = false

-- Make the left Option key a real Alt/Meta modifier (instead of typing accented
-- characters) so alt+ keybindings reach herdr. Right Option still composes.
config.send_composed_key_when_left_alt_is_pressed = false

-- Master color palette: everything inside WezTerm (shell, nvim, Claude Code)
-- inherits these 16 colors.
config.color_scheme = "Catppuccin Mocha"

return config
