-- Central LSP wiring. To add a language later:
--   1. create lua/servers/<name>.lua with its vim.lsp.config(...)
--   2. require it below and add "<name>" to the `servers` list
--   3. install the server binary (e.g. via brew/npm)
local M = {}

function M.setup()
	-- diagnostics appearance + keybindings-on-attach
	require("utils.diagnostics").setup()
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = require("utils.lsp").on_attach,
	})

	-- default capabilities for every server (from the completion engine)
	vim.lsp.config["*"] = {
		capabilities = require("blink.cmp").get_lsp_capabilities(),
	}

	-- load per-server settings
	require("servers.lua_ls")
	require("servers.efm")

	local servers = { "lua_ls", "efm" }

	-- jdtls only if the binary is installed
	if vim.fn.executable("jdtls") == 1 then
		require("servers.jdtls")
		table.insert(servers, "jdtls")
	end

	vim.lsp.enable(servers)
end

return M
