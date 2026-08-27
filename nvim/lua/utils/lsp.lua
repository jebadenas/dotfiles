-- Shared LSP helpers. `on_attach` runs whenever any language server attaches
-- to a buffer, wiring up the buffer-local keybindings.
local M = {}

function M.on_attach(ev)
	local opts = { noremap = true, silent = true, buffer = ev.buf }
	local fzf = require("fzf-lua")

	vim.keymap.set("n", "<leader>gd", function()
		fzf.lsp_definitions({ jump_to_single_result = true })
	end, opts)
	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)
	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)
	vim.keymap.set("n", "<leader>fr", fzf.lsp_references, opts)
	vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, opts)
	vim.keymap.set("n", "<leader>fw", fzf.lsp_workspace_symbols, opts)
	vim.keymap.set("n", "<leader>fi", fzf.lsp_implementations, opts)
end

return M
