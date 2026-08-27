vim.cmd("let g:netrw_banner = 0")

-- Make Homebrew tools available even when nvim is launched outside a shell,
-- and point jdtls at a Java 21+ runtime (it refuses to start on older Java).
local homebrew_bin = "/opt/homebrew/bin"
if vim.fn.isdirectory(homebrew_bin) == 1 then
	vim.env.PATH = homebrew_bin .. ":" .. vim.env.PATH
end
local java_home = vim.fn.trim(vim.fn.system("/usr/libexec/java_home -v 21 2>/dev/null"))
if vim.v.shell_error == 0 and java_home ~= "" then
	vim.env.JAVA_HOME = java_home
	vim.env.PATH = java_home .. "/bin:" .. vim.env.PATH
end

local opt = vim.opt

opt.guicursor = ""

opt.nu = true
opt.relativenumber = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.wrap = true

opt.swapfile = false
opt.backup = false
opt.undofile = true

opt.incsearch = true
opt.inccommand = "split"
opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true -- full 24-bit color for rich treesitter highlighting
opt.background = "dark"
opt.scrolloff = 8
opt.signcolumn = "yes"

opt.backspace = {"start", "eol", "indent"}

opt.splitright = true
opt.splitbelow = true

opt.updatetime = 50
opt.colorcolumn = "80"

opt.hlsearch = true
