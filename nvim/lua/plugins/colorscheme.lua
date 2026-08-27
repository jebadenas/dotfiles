-- Catppuccin colorscheme (truecolor) — matches your WezTerm/herdr Catppuccin so
-- all tools look consistent, with full rich syntax highlighting in nvim.
-- priority=1000 loads it before other plugins so there's no startup flash.
return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- latte | frappe | macchiato | mocha
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
