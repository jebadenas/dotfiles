-- LSP plugin. Actual server configs live in lua/servers/, shared helpers in
-- lua/utils/. This spec just installs nvim-lspconfig and kicks off the wiring.
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp", -- completion capabilities
		"creativenull/efmls-configs-nvim", -- linter/formatter configs for efm
	},
	config = function()
		require("servers").setup()
	end,
}
