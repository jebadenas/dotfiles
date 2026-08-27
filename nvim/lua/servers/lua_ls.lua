vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } }, -- stop "undefined global vim" warnings
			telemetry = { enable = false },
		},
	},
})
