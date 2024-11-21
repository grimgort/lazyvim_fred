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

-- local dap = require("dap")
--
-- -- Table pour sauvegarder les keymaps originales
-- local saved_keymaps = {}
--
-- -- Fonction pour sauvegarder les keymaps existantes
-- local function save_keymaps(keys)
--   for _, key in ipairs(keys) do
--     saved_keymaps[key] = vim.fn.maparg(key, "n")
--   end
-- end
--
-- -- Fonction pour restaurer les keymaps
-- local function restore_keymaps(keys)
--   for _, key in ipairs(keys) do
--     local map = saved_keymaps[key]
--     if map and map ~= "" then
--       vim.api.nvim_set_keymap("n", key, map, { noremap = false, silent = true })
--     else
--       vim.api.nvim_del_keymap("n", key)
--     end
--   end
-- end
--
-- local keys = { "<F5>", "<F10>", "<F6>" }
-- -- Fonction pour définir les keymaps pendant le debug
-- local function setup_dap_ui_keymaps()
--   -- Liste des keymaps à sauvegarder et à redéfinir
--
--   save_keymaps(keys)
--
--   -- Keymaps standards pour DAP
--   vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
--   vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
--   vim.keymap.set("n", "<F6>", dap.run_to_cursor, { desc = "DAP run_to_cursor" })
--   -- vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP Step Into" })
--   -- vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "DAP Step Out" })
--   -- vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
-- end
--
-- -- Supprimer les keymaps après le debug et restaurer les anciennes
-- local function teardown_dap_ui_keymaps()
--   restore_keymaps(keys)
-- end
--
-- -- Configurer les événements pour activer/désactiver les keymaps et dap-ui
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "DapStarted",
--   callback = function()
--     setup_dap_ui_keymaps()
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "DapStopped",
--   callback = function()
--     teardown_dap_ui_keymaps()
--   end,
-- })
