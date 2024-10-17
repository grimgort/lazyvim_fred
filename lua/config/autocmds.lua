-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- ##wrap preview with telescope
vim.cmd([[autocmd User TelescopePreviewerLoaded setlocal wrap]])

vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None",
})

-- # force l'écriture des shada qui plante tout le temps
vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*",
  command = "rshada!",
})
