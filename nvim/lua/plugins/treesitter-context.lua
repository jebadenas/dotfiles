-- Sticky header showing the function/class you're currently inside when the
-- declaration scrolls off the top of the screen.
return {
	"nvim-treesitter/nvim-treesitter-context",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		max_lines = 3, -- cap the sticky header at 3 lines
	},
}
