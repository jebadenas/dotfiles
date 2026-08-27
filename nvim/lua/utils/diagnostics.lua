-- How diagnostics (errors/warnings) look: gutter signs, inline text, popups.
local M = {}

function M.setup()
	local signs = {
		Error = "\u{f057} ",
		Warn = "\u{f071} ",
		Hint = "\u{ea61}",
		Info = "\u{f05a}",
	}

	vim.diagnostic.config({
		virtual_text = { prefix = "●", spacing = 4 },
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = signs.Error,
				[vim.diagnostic.severity.WARN] = signs.Warn,
				[vim.diagnostic.severity.INFO] = signs.Info,
				[vim.diagnostic.severity.HINT] = signs.Hint,
			},
		},
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			source = true,
			header = "",
			prefix = "",
			focusable = false,
			style = "minimal",
		},
	})

	-- give hover / signature popups a rounded border too
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

return M
