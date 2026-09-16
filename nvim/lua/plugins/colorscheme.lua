-- Catppuccin colorscheme (truecolor) — matches your WezTerm/herdr Catppuccin so
-- all tools look consistent, with full rich syntax highlighting in nvim.
-- priority=1000 loads it before other plugins so there's no startup flash.
return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "latte", -- latte (light) | frappe | macchiato | mocha
		})
		vim.cmd.colorscheme("catppuccin")

		-- Strong contrast for light backgrounds: dark cursor, clear visual selection.
		vim.api.nvim_set_hl(0, "Cursor", { fg = "#eff1f5", bg = "#1e1e2e" })
		vim.api.nvim_set_hl(0, "lCursor", { fg = "#eff1f5", bg = "#1e1e2e" })
		vim.api.nvim_set_hl(0, "CursorIM", { fg = "#eff1f5", bg = "#1e1e2e" })
		vim.api.nvim_set_hl(0, "Visual", { bg = "#acb0be" })
	end,
}
