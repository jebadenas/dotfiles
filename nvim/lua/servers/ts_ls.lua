vim.lsp.config("ts_ls", {
	-- ts_ls auto-detects each project via package.json / jsconfig / tsconfig,
	-- so React 19 types come from that project's node_modules (@types/react).
})
