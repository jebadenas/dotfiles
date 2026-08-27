-- Fuzzy finder: files, live grep, buffers, diagnostics.
return {
	"ibhagwan/fzf-lua",
	config = function()
		require("fzf-lua").setup({
			files = {
				cmd = "fd --color=never --type f --hidden --follow --exclude .git",
			},
		})

		local fzf = require("fzf-lua")
		vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "FZF Files" })
		vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "FZF Live Grep" })
		vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "FZF Buffers" })
		vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "FZF Help Tags" })
		vim.keymap.set("n", "<leader>fx", fzf.diagnostics_document, { desc = "FZF Diagnostics Document" })
		vim.keymap.set("n", "<leader>fX", fzf.diagnostics_workspace, { desc = "FZF Diagnostics Workspace" })
	end,
}
