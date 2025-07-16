local fterm = require("FTerm")

local gitui = fterm:new({
    ft = 'fterm_gitui', -- You can also override the default filetype, if you want
    cmd = "pwsh",
    dimensions = {
        height = 0.9,
        width = 0.9
    }
})

function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end


vim.keymap.set("v", "<A-g>", ":RipSubstitute<CR>")
vim.keymap.set("n", "<A-g>", ":.RipSubstitute<CR>")

vim.keymap.set("n", "<space>bb", ":lua require('arena').toggle()<CR>")


vim.api.nvim_set_keymap('n', '<space>xX', '', {
 desc = "populate trouble for workspace diagnostique" ,
  noremap = true,
  callback = function()
    for _, client in ipairs(vim.lsp.buf_get_clients()) do
      require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
    end
  end
})

-- Use this to toggle gitui in a floating terminal
-- vim.keymap.set('n', '<A-g>', function()
--     gitui:toggle()
-- end)
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- local function remap_bracket_commands()
--   local mappings = {
--     ["[C"] = "ùC", -- Goto previous end @class.outer
--     ["[A"] = "ùA", -- Goto previous end @parameter.inner
--     ["[F"] = "ùF", -- Goto previous end @function.outer
--     ["[f"] = "ùf", -- Goto previous start @function.outer
--     ["[a"] = "ùa", -- Goto previous start @parameter.inner
--     ["[c"] = "ùc", -- Goto previous start @class.outer
--     ["[H"] = "ùH", -- First Hunk
--     ["[h"] = "ùh", -- Prev Hunk
--     ["["] = "ù", -- General remap of '[' to 'ù'
--   }
--
--   -- Remapper les commandes
--   for original, new in pairs(mappings) do
--     -- Remap pour le mode normal
--     vim.keymap.set("n", new, ":" .. original .. "<CR>", { noremap = true, silent = true })
--
--     -- Remap pour les autres modes si nécessaire
--     vim.keymap.set("x", new, ":" .. original .. "<CR>", { noremap = true, silent = true })
--     vim.keymap.set("o", new, ":" .. original .. "<CR>", { noremap = true, silent = true })
--   end
-- end
--
-- -- Exécuter la fonction de remapping

vim.keymap.set("v", "<C-c>", "y`]", { noremap = true })
vim.keymap.set("n", "<C-v>", "P", {})
vim.keymap.set("i", "<C-v>", "P", {})
-- vim.keymap.set("n", "p", "P", {})
-- remap_bracket_commands()
vim.keymap.set("n",'<leader>"','gsaiw"',{remap = true})
-- Remapper les touches Ctrl+h, Ctrl+j, Ctrl+k, et Ctrl+l pour se déplacer en mode insert
vim.keymap.set(
  "n",
  "<A-h>",
  ":lua require('grug-far').open({ prefills = { paths = vim.fn.expand('%'), search = vim.fn.expand('<cword>') }, flags = '--fixed-string' })<cr>",
  {}
)
vim.keymap.set(
  "v",
  "<A-h>",
  ":<C-u>lua require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand('%') } })<cr>",
  {}
)
vim.keymap.set(
  "n",
  "<A-s>",
  ":lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') }, flags = '-i' })<cr>",
  {}
)
vim.keymap.set(
  "v",
  "<A-s>",
  ":lua require('grug-far').with_visual_selection({ prefills = { search = vim.fn.expand('%') }, flags = '-i' })<cr>",
  {}
)


vim.keymap.set("i", "<A-j>", "<Down>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-h>", "<Left>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-k>", "<Up>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-l>", "<Right>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>l", "", { desc = "lspFred" })
vim.keymap.set("n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next()<cr>", {})
vim.keymap.set("n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev()<cr>", {})
vim.keymap.set(
  "n", -- Mode normal
  "<leader>dd", -- Raccourci clavier (par exemple, leader + d + r pour "repl")
  ":lua require('dapui').float_element('repl', { enter = true })<CR>", -- Ouvre ou ferme la fenêtre REPL
  { noremap = true, silent = true } -- Options
)
vim.keymap.set(
  "n", -- Mode normal
  "<leader>df", -- Raccourci clavier (par exemple, leader + d + r pour "repl")
  ":lua require('dapui').float_element('stacks', { enter = true })<CR>", -- Ouvre ou ferme la fenêtre REPL
  { desc = "DAP float stacks"  } -- Options
)
vim.keymap.set(
  "n", -- Mode normal
  "<leader>dz", -- Raccourci clavier (par exemple, leader + d + r pour "repl")
  ":lua require('dapui').float_element('console', { enter = true })<CR>", -- Ouvre ou ferme la fenêtre REPL
  { noremap = true, silent = true } -- Options
)
vim.keymap.set(
  "n", 
  "<leader>dh",
  ":lua require('dapui').elements.watches.add(vim.fn.expand('<cword>'))<CR>", -- Ouvre ou ferme la fenêtre REPL
  { noremap = true, silent = true } -- Options
)
vim.keymap.set(
  "v", 
  "<leader>dh",
  ":lua require('dapui').elements.watches.add(get_visual_selection())<CR>", -- Ouvre ou ferme la fenêtre REPL
  { noremap = true, silent = true } -- Options
)
vim.keymap.set(
  "n", -- Mode normal
  "<leader>dn", -- Nouvelle combinaison de touches (par exemple, leader + d + n pour "next")
  ":lua require('dap').step_over()<CR>", -- Appeler la fonction step_over de nvim-dap
  { noremap = true, silent = true } -- Options
)
-- vim.keymap.set(
--   "n", -- Mode normal
--   "ù", -- La touche que vous remappez
--   "[", -- Commande à exécuter (vous pouvez la remplacer par autre chose)
--   { noremap = true, silent = true } -- Options
-- )
vim.keymap.set("n", "ç", '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set("t", "ç", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>nn", "<cmd>Telekasten find_notes<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>nb", "<cmd>Telekasten new_note<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>nf", "<cmd>Telekasten search_notes<CR>", { noremap = true, silent = false })

vim.keymap.set("n", "<A-a>", function()
  require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "<A-x>", function()
  require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("n", "g<A-a>", function()
  require("dial.map").manipulate("increment", "gnormal")
end)
vim.keymap.set("n", "g<A-x>", function()
  require("dial.map").manipulate("decrement", "gnormal")
end)
vim.keymap.set("v", "<A-a>", function()
  require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("v", "<A-x>", function()
  require("dial.map").manipulate("decrement", "visual")
end)
vim.keymap.set("v", "g<A-a>", function()
  require("dial.map").manipulate("increment", "gvisual")
end)
vim.keymap.set("v", "g<A-x>", function()
  require("dial.map").manipulate("decrement", "gvisual")
end)

-- vim.keymap.set({ "n", "x" }, "<leader>se", function()
--   require("ssr").open()
-- end)
-- vim.keymap.set("n", "<C-j>", "[", { noremap = true, silent = false })
-- vim.keymap.set("n", ")", "]", { noremap = true, silent = false })
--
--
vim.keymap.set(
  "n",
  "<leader>sz",
  "<cmd>lua require('grug-far').open({ prefills = { paths = vim.fn.expand(' % ') }, flags = '-i' })<CR>",
  {}
)

-- vim.keymap.set(
--   "n",
--   "<leader>dd",
--   "<cmd>lua require('dap.ext.vscode').load_launchjs(nil, { codelldb= { 'c', 'cpp' } })<CR>",
--   { silent = true, noremap = true }
-- )

local opt = {}
vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab>e", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>b", "<cmd>tabclose<cr>", { desc = "Close Tab" })

vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineCyclePrev<cr>", opt)
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCycleNext<cr>", opt)
--
vim.keymap.set("n", "<leader>bH", "<cmd>BufferLineCloseRight<cr>", opt)
vim.keymap.set("n", "<leader>bL", "<cmd>BufferLineCloseLeft<cr>", opt)

vim.keymap.set("n", "<leader>e", "", { desc = "Neotree" })
vim.keymap.set("n", "<leader>ee", "<cmd>Neotree toggle<CR>", opt)
vim.keymap.set("n", "<leader>ef", "<cmd>:Neotree reveal<CR>", opt)

vim.keymap.set("n", "<leader>gj", "<cmd>lua require 'gitsigns'.nav_hunk('next',{target='all'})<cr>", opt)
vim.keymap.set("n", "<leader>gk", "<cmd>lua require 'gitsigns'.nav_hunk('prev',{target='all'})<cr>", opt)
vim.keymap.set("n", "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", opt)
vim.keymap.set("n", "<leader>gn", "<cmd>Neogit<cr>", opt)
vim.keymap.set("n", "<leader>gr", ":lua require('git-log').check_log()<cr>", opt)
vim.keymap.set("v", "<leader>gr", ":lua require('git-log').check_log()<cr>", opt)
-- vim.keymap.set("n", "<leader>gf", ":Telescope git_branches<cr>", opt)

-- vim.keymap.set("n", "<leader>gf", ":lua require('vgit').buffer_history_preview()<cr>", opt)

-- vim.keymap.set("n", "<leader>gg", "<cmd>lua Snacks.lazygit.open()<cr>", opt)

vim.keymap.set("n", "<leader>hj", "<cmd>lua vim.diagnostic.goto_next()<cr>", opt)
vim.keymap.set("n", "<leader>hk", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opt)

vim.keymap.set("n", "<leader>dq", "<cmd>e ./.vscode/launch.json<CR>", { silent = true, noremap = true })

-- vim.keymap.set("n", "<F8>", ":CMakeBuild <cr>", opt)
-- vim.keymap.set("n", "<F5>", ":Task start cmake configure<cr>", opt)
-- vim.keymap.set("n", "<F6>", ":Task start cmake build_all -j10 --config Release<cr>", opt)
-- vim.keymap.set("n", "<F7>", ":Task start cmake build_all -j10 <cr>", opt)

vim.keymap.set("n", "<F5>", ":AsyncRun cmake -S . -B build<cr>", opt)
vim.keymap.set("n", "<F6>", ":AsyncRun cmake --build build --config Release -j10<cr>", opt)
vim.keymap.set("n", "<F7>", ":AsyncRun cmake --build build --config Debug -j10<cr>", opt)
-- vim.keymap.set("n", "<F7>", ':AsyncRun pwsh -Command "frintelcompile"<cr>', opt)
vim.keymap.set("n", "<F9>", ':AsyncRun pwsh -Command "frintelcompile"<cr>', opt)
vim.keymap.set("v", "*", [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], {})
-- vim.keymap.set("n", "<C-!>", ":%s/", opt)
-- vim.keymap.set("v", "<C-!>", ":s/", opt)
vim.keymap.set("n", "<C-a>", "GVgg", opt)

-- vim.keymap.set("n","<S-Insert>","<C-R>+",opt)
-- vim.keymap.set("n", "P", "<cmd>Telescope projects<cr>", opt)

vim.keymap.set("n", "<leader>zvf", ":DiffviewFileHistory<cr>", opt)
vim.keymap.set("n", "<leader>zvo", ":DiffviewOpen<cr>", opt)
vim.keymap.set("n", "<leader>zd", ":DevDocsUnderCursor<cr>", opt)
-- vim.keymap.set("n", "<leader>zd",":DevDocsUnderCursor<cr>",opt)
-- vim.keymap.set("n", "<leader>zn",":edit ~/NEORG/index.norg<cr>",opt)

vim.keymap.set("n", "<leader>zz", ":only<cr>", opt)
-- vim.keymap.set("n", "<leader>za", ":tabnew<cr>", opt)
--[[ vim.keymap.set("n", "²", ":CloseAll<cr>", opt) ]]
--[[ vim.keymap.set("i", "²", "<C-o>:CloseAll<cr>", opt) ]]
--[[ vim.keymap.set("t", "²", "<C-\\><C-n>CloseAll<cr>", opt) ]]
vim.keymap.set("n", "²", ":lua QuitAllLua()<cr>", { silent = true })
vim.keymap.set("i", "²", "<C-o>:lua QuitAllLua()<cr>", { silent = true })

vim.keymap.set("t", "²", "<C-\\><C-n>:lua QuitAllLua()<cr>", { noremap = true, silent = true })

vim.keymap.set("t", "<C-a>", "<C-\\><C-n>", opt)
vim.keymap.set("t", "<C-j>", [[<DOWN>]], opt)
vim.keymap.set("t", "<C-k>", [[<UP>]], opt)
vim.keymap.set("n", "<leader>zq", "<cmd>copen<CR>", opt)
-- vim.keymap.set("n", "<F7>","<cmd>CMake build_all<CR>",opt)

vim.keymap.set("v", "*", [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], opt)
vim.keymap.set("n", "<leader>zh", [[:%s/<c-r><c-w>/<c-r><c-w>/g]], opt)
vim.keymap.set("n", "<leader>zc", ":Telescope grep_string<cr>", opt)
-- vim.keymap.set("n", "<leader>ff", ":Telescope git_files<cr>", opt)
vim.keymap.set("n", "<leader><leader>", ":Telescope find_files no_ignore=false<cr>", opt)
vim.keymap.set("n", "<leader>ff", ":Telescope find_files hidden=true no_ignore=true<cr>", opt)
-- vim.keymap.set("n", "<leader>fg", ":Telescope find_files hidden=true no_ignore=true<cr>", opt)
vim.keymap.set("n", "<leader>zm", "<cmd>Glow<cr>", opt)
vim.keymap.set("n", "<leader>zp", "<cmd>MarkdownPreview<cr>", opt)

vim.keymap.set("n", "<leader>td", ":Translate fr<cr>", opt)
vim.keymap.set("v", "<leader>td", ":Translate fr<cr>", opt)
vim.keymap.set("n", "<leader>tr", ":Translate en<cr>", opt)
vim.keymap.set("v", "<leader>tr", ":Translate en<cr>", opt)
vim.keymap.set("n", "<leader>ta", ":Translate fr --output=replace<cr>", opt)
vim.keymap.set("v", "<leader>ta", ":Translate fr --output=replace<cr>", opt)
vim.keymap.set("n", "<leader>tz", ":Translate en --output=replace <cr>", opt)
vim.keymap.set("v", "<leader>tz", ":Translate en --output=replace <cr>", opt)

vim.keymap.set("n", "<C-:>", ":Telescope commands<cr>", opt)
vim.keymap.set("n", "!", ":Telescope commands<cr>", opt)
vim.keymap.set("n", "<C-;>", ":Telescope keymaps<cr>", opt)
vim.keymap.set("n", "<C-!>", "<cmd>Telescope command_history<cr>", opt)

-- Moving the cursor through long soft-wrapped lines
-- vim.keymap.set("n", "j", "gj", opt)
-- vim.keymap.set("n", "k", "gk", opt)

-- navigation
vim.keymap.set("i", "<A-Up>", "<C-\\><C-N><C-w>k", opt)
vim.keymap.set("i", "<A-Down>", "<C-\\><C-N><C-w>j", opt)
vim.keymap.set("i", "<A-Left>", "<C-\\><C-N><C-w>h", opt)
vim.keymap.set("i", "<A-Right>", "<C-\\><C-N><C-w>l", opt)

-- Resize with arrows
-- vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opt)
-- vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opt)
-- vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opt)
-- vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opt)

-- QuickFix
vim.keymap.set("n", "<leader>zpj", ":cnext<CR>", opt)
vim.keymap.set("n", "<leader>zpk", ":cprev<CR>", opt)
vim.keymap.set("n", "<leader>zpo", ":copen<CR>", opt)

vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h", opt)
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j", opt)
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k", opt)
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l", opt)

-- Better indenting
vim.keymap.set("v", "<", "<gv", opt)
vim.keymap.set("v", ">", ">gv", opt)

-- Move selected line / block of text in visual mode
-- vim.keymap.set("gv","K",":move '<-2<CR>gv-gv",opt)
-- vim.keymap.set("gv","J",":move '>+1<CR>gv-gv",opt)

-- Move current line / block with Alt-j/k ala vscode.
-- vim.keymap.set("gv","<A-j>",":m '>+1<CR>gv-gv",opt)
-- vim.keymap.set("gv","<A-k>",":m '<-2<CR>gv-gv",opt)

-- navigate tab completion with <c-j> and <c-k>
-- runs conditionally
-- ["<C-j>"] = { 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', { expr = true, noremap = true } },
-- ["<C-k>"] = { 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', { expr = true, noremap = true } },

--[[ vim.set.keymap("n","q","<cmd>lua require('utils.settings.functions').smart_quit()<CR>", opt) ]]

vim.keymap.set("n", "<leader>zhz", "<Cmd>ClangdSwitchSourceHeader<CR>", opt)

vim.keymap.set("c", "<S-k>", "<UP>", opt)
vim.keymap.set("c", "<S-j>", "<DOWN>", opt)
-- vim.keymap.set("n", "<leader>q", "<cmd>lua smart_quit()<cr>", opt)
--[[ vim.keymap.set("n", "<leader>q", "<cmd>lua QuitAllLua()<cr>", opt) ]]

-- vim.keymap.set("n", "<leader>gao", "<Plug>(git-conflict-ours)")
-- vim.keymap.set("n", "<leader>gat", "<Plug>(git-conflict-theirs)")
-- vim.keymap.set("n", "<leader>gab", "<Plug>(git-conflict-both)")
-- vim.keymap.set("n", "<leader>ga0", "<Plug>(git-conflict-none)")
-- vim.keymap.set("n", "<leader>gak", "<Plug>(git-conflict-prev-conflict)")
-- vim.keymap.set("n", "<leader>gaj", "<Plug>(git-conflict-next-conflict)")

-- vim.keymap.set("n", "<leader>gah", "<CMD>diffg RE<CR>", opt)
-- vim.keymap.set("n", "<leader>gab", "<CMD>diffg LO<CR>", opt)
-- vim.keymap.set("n", "<leader>gal", "<CMD>diffg BA<CR>", opt)

-- vim.keymap.set("n", "<leader>gas", "<CMD>Gdiffsplit<CR>", opt)

vim.keymap.set("n", "<leader>zvv", "<cmd>windo diffthis<cr>")
vim.keymap.set("n", "<leader>zvf", "<cmd>diffoff!<cr>")
-- vim.keymap.set("n", "<leader>ss", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
-- vim.keymap.set("n", "<F4>", "<cmd>MundoToggle<cr>")

--[[ remap recorder ]]
vim.keymap.set("n", "Q", "q")
vim.keymap.set("n", "q", "<Nop>")

vim.keymap.set("n", "<F12>", "<cmd>Colorbox shuffle<CR>")
vim.keymap.set("n", "<F1>", require("dap").continue, { desc = "DAP Continue" })
vim.keymap.set("n", "<F2>", require("dap").step_over, { desc = "DAP Step Over" })
vim.keymap.set("n", "<F3>", require("dap").run_to_cursor, { desc = "DAP run_to_cursor" })

--LazyVim
-- tabs
-- vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
-- vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
-- vim.keymap.set("n", "<leader><tab>e", "<cmd>tabnew<cr>", { desc = "New Tab" })
-- vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
-- vim.keymap.set("n", "<leader><tab>b", "<cmd>tabclose<cr>", { desc = "Close Tab" })
-- vim.keymap.set("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

vim.keymap.set("n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", opt)
vim.keymap.set("n", "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", opt)
vim.keymap.set("n", "gpc", "<cmd>lua require('goto-preview').close_all_win()<CR>", opt)
vim.keymap.set("n", "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", opt)

-- vim.keymap.set("n", "s", "<cmd>HopChar1<cr>", { silent = true })
-- vim.keymap.set("n", "S", "<cmd>HopWord<cr>", { silent = true })
-- vim.keymap.set("v", "s", "<cmd>HopChar1<cr>", { silent = true })
-- vim.keymap.set("v", "S", "<cmd>HopWord<cr>", { silent = true })
-- vim.keymap.set("n", "<cr>", "<cmd>HopWord<cr>", { silent = true })

vim.cmd([[
" nnoremap << >>
" nnoremap >> <<
" vnoremap << >gv
" vnoremap >> <gv
" nnoremap dd "_dd
" nnoremap d "_d
" vnoremap d "_d
" nnoremap D "_D
" vnoremap D "_D
" nnoremap x "_x
" vnoremap x "_x
" nnoremap cc dd
" nnoremap c d
" vnoremap c d
noremap <Del> "_x
map! <S-Insert> <C-R>+
]])

--[[ local M = {} ]]
-- Définir des mappings pour le mode normal (nnoremap)
-- vim.api.nvim_set_keymap("n", "<<", ">>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", ">>", "<<", { noremap = true, silent = true })
--
-- -- Définir des mappings pour le mode visuel (vnoremap)
-- vim.api.nvim_set_keymap("v", "<<", ">gv", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", ">>", "<gv", { noremap = true, silent = true })
--
-- -- Définir des mappings pour supprimer sans copier dans le registre par défaut (nnoremap)
-- -- vim.api.nvim_set_keymap("n", "dd", "_dd", { noremap = true, silent = true })
-- -- vim.api.nvim_set_keymap("n", "d", "_d", { noremap = true, silent = true })
-- -- vim.api.nvim_set_keymap("n", "x", "_x", { noremap = true, silent = true })
-- -- vim.api.nvim_set_keymap("n", "D", "_D", { noremap = true, silent = true })
--
-- -- Même chose pour le mode visuel (vnoremap)
-- -- vim.api.nvim_set_keymap("v", "d", "_d", { noremap = true, silent = true })
-- -- vim.api.nvim_set_keymap("v", "x", "_x", { noremap = true, silent = true })
-- -- vim.api.nvim_set_keymap("v", "D", "_D", { noremap = true, silent = true })
--
-- -- Mappings pour changer le texte (cc, c, et leurs variantes)
-- vim.api.nvim_set_keymap("n", "cc", "dd", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "c", "d", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "c", "d", { noremap = true, silent = true })
--
-- -- Mapping pour supprimer avec la touche de suppression (<Del>)
-- vim.api.nvim_set_keymap("n", "<Del>", "_x", { noremap = true, silent = true })
--
-- -- Mapping pour insérer le contenu du presse-papiers système avec <S-Insert> en mode insertion (map!)
-- vim.api.nvim_set_keymap("i", "<S-Insert>", "<C-R>+", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("c", "<S-Insert>", "<C-R>+", { noremap = true, silent = true })

function Smart_quit()
  local bufnr = vim.api.nvim_get_current_buf()
  local modified = vim.api.nvim_buf_get_var(bufnr, "modified")
  if modified then
    vim.ui.input({
      prompt = "You have unsaved changes. Quit anyway? (y/n) ",
    }, function(input)
      if input == "y" then
        vim.cmd("q!")
      end
    end)
  else
    vim.cmd("q!")
  end
end

function QuitAllLua()
  vim.cmd([[call feedkeys("\<esc>")]])
  vim.cmd([[call feedkeys("q")]])
  vim.cmd([[call feedkeys("\<esc>")]])
  vim.cmd("pclose")
  vim.cmd("helpclose")
  vim.cmd("ccl")
  -- vim.cmd("NvimTreeClose")
  if vim.fn.exists(":DiffviewClose") == 2 then
    vim.cmd("DiffviewClose")
  end
  vim.cmd("nohlsearch")
  -- vim.cmd("TroubleClose")
  if vim.fn.exists(":Neotree") == 2 then
    vim.cmd("Neotree close")
  end
  if vim.fn.exists(":Neotest") == 2 then
    vim.cmd("Neotest summary close")
  end
  -- vim.cmd("SymbolsOutlineClose")
  --[[ vim.cmd("Lspsaga close_floaterm") ]]

  if vim.fn.exists(":FTerm") == 2 then
    require("FTerm").close()
  end
  --[[ :pclose ]]
  --[[   helpclose ]]
  --[[   ccl ]]
  require("goto-preview").close_all_win()
  -- require("notify").dismiss({ silent = true, pending = true })
end

function system_open(path)
  local cmd
  if vim.fn.has("win32") == 1 and vim.fn.executable("explorer") == 1 then
    cmd = { "cmd.exe", "/K", "explorer" }
  elseif vim.fn.has("unix") == 1 and vim.fn.executable("xdg-open") == 1 then
    cmd = { "xdg-open" }
  elseif (vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1) and vim.fn.executable("open") == 1 then
    cmd = { "open" }
  end
  vim.fn.jobstart(vim.fn.extend(cmd, { path or vim.fn.expand("<cfile>") }), { detach = true })
end
--
-- vim.api.nvim_create_user_command("Format", function(args)
--   local range = nil
--   if args.count ~= -1 then
--     local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
--     range = {
--       start = { args.line1, 0 },
--       ["end"] = { args.line2, end_line:len() },
--     }
--   end
--   require("conform").format({ async = true, lsp_fallback = true, range = range })
-- end, {
--   range = true,
-- })

local dap = require("dap")
-- dap.adapters.python = function(cb, config)
--   if config.request == "attach" then
--     ---@diagnostic disable-next-line: undefined-field
--     local port = (config.connect or config).port
--     ---@diagnostic disable-next-line: undefined-field
--     local host = (config.connect or config).host or "127.0.0.1"
--     cb({
--       type = "server",
--       port = assert(port, "`connect.port` is required for a python `attach` configuration"),
--       host = host,
--       options = {
--         source_filetype = "python",
--       },
--     })
--   else
--     cb({
--       type = "executable",
--       command = "path/to/virtualenvs/debugpy/bin/python",
--       args = { "-m", "debugpy.adapter" },
--       options = {
--         source_filetype = "python",
--       },
--     })
--   end
-- end
--
-- dap.configurations.python = {
--   {
--     -- The first three options are required by nvim-dap
--     type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
--     request = "launch",
--     name = "Launch file",
--
--     -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
--
--     program = "${file}", -- This configuration will launch the current file if used.
--     pythonPath = function()
--       -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
--       -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
--       -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
--       local cwd = vim.fn.getcwd()
--       if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
--         return cwd .. "/venv/bin/python"
--       elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
--         return cwd .. "/.venv/bin/python"
--       else
--         return "/usr/bin/python"
--       end
--     end,
--   },
-- }
-- dap.adapters.cpp = {
--   type = "executable",
--   command = "cppvsdbg",
--   -- env = {
--   -- 	LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES",
--   -- },
--   name = "cppvsdbg",
-- }
-- dap.configurations.cpp = {
--   {
--     name = "Launch",
--     type = "cpp",
--     request = "launch",
--     -- program = function()
--     -- 	return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
--     -- end,
--     -- cwd = "${workspaceFolder}",
--     -- args = {},
--   },
-- }
-- dap.configurations.c = dap.configurations.cpp

-- require('dap.ext.vscode').json_decode = require('json5').parse
--
--
vim.keymap.set("n", "<F4>", function()
  -- local dap = require("dap")
  if dap.session() == nil then
    -- Only call this on C++ and C files
    require("ctest-telescope").pick_test_and_debug()
  else
    dap.continue()
  end
end, {
  desc = "Debug: Start/Continue",
})
--
-- dap.configurations.cpp = {
--   {
--     name = "Launch",
--     type = "codelldb",
--     request = "launch",
--     cwd = "${workspaceFolder}",
--     stopOnEntry = true,
--     args = {},
--     runInTerminal = true,
--     options = {
--       expressions = "native", -- Activation de l'option expressions
--     },
--   },
-- }
--
-- -- Pour C/C++
-- dap.configurations.c = dap.configurations.cpp
-- dap.configurations.rust = dap.configurations.cpp
