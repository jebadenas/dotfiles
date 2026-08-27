local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- move between split windows (inside nvim; herdr handles panes separately)
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- create splits
keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Split window horizontally" })

keymap.set("n", "<leader>e", "<Cmd>Ex<CR>", { desc = "Open file explorer" })

keymap.set("n", "<leader>nh", "<Cmd>nohl<CR>") -- clear search highlight
keymap.set("n", "x", '"_x')                    -- delete char without copying to register
keymap.set("x", "<leader>p", '"_dP')           -- replace and paste


keymap.set("n", "<leader>to", "<Cmd>tabnew<CR>")   -- new tab
keymap.set("n", "<leader>tx", "<Cmd>tabclose<CR>") -- close tab

keymap.set("n", "<leader>bn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete current buffer" })

-- copying to system clipboard
keymap.set("n", "<leader>y", '"+y')
keymap.set("v", "<leader>y", '"+y')
keymap.set("n", "<leader>Y", '"+Y')

-- deleting without yanking
keymap.set("n", "<leader>d", '"_d')
keymap.set("v", "<leader>d", '"_d')


