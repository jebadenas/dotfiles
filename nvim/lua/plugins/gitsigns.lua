-- Shows git add/change/delete markers in the sign column + hunk keymaps.
return {
	"lewis6991/gitsigns.nvim",
	opts = {
		attach_to_untracked = true,
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation between hunks
			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, { desc = "Next Git Hunk" })

			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, { desc = "Prev Git Hunk" })

			-- Hunk / Git actions
			map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview Git Hunk" })
			map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage Git Hunk" })
			map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset Git Hunk" })
			map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo Stage Hunk" })
			map("n", "<leader>hb", function()
				gitsigns.blame_line({ full = true })
			end, { desc = "Git Blame Line" })
		end,
	},
}
