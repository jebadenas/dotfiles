-- efm-langserver: a generic server that runs external linters/formatters.
-- Here it runs luacheck (lint) + stylua (format) on Lua files.
local luacheck = require("efmls-configs.linters.luacheck")
local stylua = require("efmls-configs.formatters.stylua")

vim.lsp.config("efm", {
	filetypes = { "lua" },
	init_options = { documentFormatting = true },
	settings = {
		languages = {
			lua = { luacheck, stylua },
		},
	},
})

-- format Lua on save via efm
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.lua",
	callback = function(args)
		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end,
})
