-- Statusline: the configurable bar at the bottom (mode, git, file, diagnostics).
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- filetype icons (needs a Nerd Font)
	opts = {
		options = {
			theme = "auto", -- matches the active kanagawa colorscheme
			globalstatus = true, -- one statusline for the whole window, not per-split
			section_separators = { left = "", right = "" },
			component_separators = { left = "", right = "" },
		},
	},
}
