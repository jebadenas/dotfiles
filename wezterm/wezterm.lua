local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 15
config.window_decorations = "RESIZE"

config.colors = {
  foreground = "#D8DEE9",
  background = "#2E3440",
  cursor_bg = "#88C0D0",
  cursor_border = "#88C0D0",
  cursor_fg = "#2E3440",
  selection_bg = "#4C566A",
  selection_fg = "#D8DEE9",
  ansi = { "#3B4252", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#88C0D0", "#E5E9F0" },
  brights = { "#434C5E", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#88C0D0", "#ECEFF4" },
}

return config
