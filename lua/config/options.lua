-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- vim.g.lazyvim_picker = "telescope"
vim.g.maplocalleader = ";"

vim.g.root_spec = { ".git" }
-- vim.g.rooter_patterns = { ".git" }
-- vim.g.root_lsp_ignore = true

-- vim.opt.bg = "light" -- probablement inutile
-- vim.opt.wrap = true -- bug with treesitter context
vim.opt.spell = false -- remplacé par ltex
vim.opt.spelllang = {}
vim.o.inccommand = "split"
if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  vim.g.neovide_cursor_animation_length = 0.
  vim.g.neovide_cursor_trail_size = 0.
else
  vim.o.guifont = "JetBrains Mono:h13"
end
-- vim.o.guifont = "Source Code Pro:h14" -- text below applies for VimScript

--disable default neovim colorshema
vim.o.wildignore = vim.o.wildignore
  .. ",blue.vim,darkblue.vim,default.vim,delek.vim,desert.vim,"
  .. "elflord.vim,evening.vim,industry.vim,koehler.vim,morning.vim,murphy.vim,"
  .. "pablo.vim,peachpuff.vim,ron.vim,shine.vim,slate.vim,torte.vim,zellner.vim"

vim.opt.clipboard = "unnamedplus"
vim.wo.relativenumber = false

if vim.loop.os_uname().sysname == "Windows_NT" then
  LazyVim.terminal.setup("pwsh")
end
vim.opt.swapfile = false
-- local default_options = {
--    backup = false, -- creates a backup file
--    clipboard = "unnamedplus", -- allows neovim to access the system clipboard
--    cmdheight = 1, -- more space in the neovim command line for displaying messages
--    completeopt = { "menuone", "noselect" },
--    conceallevel = 0, -- so that `` is visible in markdown files
--    fileencoding = "utf-8", -- the encoding written to a file
--    foldmethod = "manual", -- folding, set to "expr" for treesitter based folding
--    foldexpr = "", -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
--    hidden = true, -- required to keep multiple buffers and open multiple buffers
--    hlsearch = true, -- highlight all matches on previous search pattern
--    ignorecase = true, -- ignore case in search patterns
--    mouse = "a", -- allow the mouse to be used in neovim
--    pumheight = 10, -- pop up menu height
--    showmode = false, -- we don't need to see things like -- INSERT -- anymore
--    smartcase = true, -- smart case
--    splitbelow = true, -- force all horizontal splits to go below current window
--    splitright = true, -- force all vertical splits to go to the right of current window
--    swapfile = false, -- creates a swapfile
--    termguicolors = true, -- set term gui colors (most terminals support this)
--    timeoutlen = 1000, -- time to wait for a mapped sequence to complete (in milliseconds)
--    title = true, -- set the title of window to the value of the titlestring
--    -- opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
--    undodir = undodir, -- set an undo directory
--    undofile = true, -- enable persistent undo
--    updatetime = 100, -- faster completion
--    writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
--    expandtab = true, -- convert tabs to spaces
--    shiftwidth = 2, -- the number of spaces inserted for each indentation
--    tabstop = 2, -- insert 2 spaces for a tab
--    cursorline = true, -- highlight the current line
--    number = true, -- set numbered lines
--    numberwidth = 4, -- set number column width to 2 {default 4}
--    signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
--    wrap = false, -- display lines as one long line
--    shadafile = join_paths(get_cache_dir(), "lvim.shada"),
--    scrolloff = 8, -- minimal number of screen lines to keep above and below the cursor.
--    sidescrolloff = 8, -- minimal number of screen lines to keep left and right of the cursor.
--    showcmd = false,
--    ruler = false,
--    laststatus = 3,
--  }
