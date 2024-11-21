return {

  ------------------ special lazyvim ------------------------
  ---Use <tab> for completion and snippets (supertab).
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
  -- change some telescope options and a keymap to browse plugin files
  {
    "nvimdev/dashboard-nvim",
    lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
    opts = function()
      local logo = [[
███████ ██████  ███████ ██████      ███    ██ ███████  ██████  ██    ██ ██ ███    ███ 
██      ██   ██ ██      ██   ██     ████   ██ ██      ██    ██ ██    ██ ██ ████  ████ 
█████   ██████  █████   ██   ██     ██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██ 
██      ██   ██ ██      ██   ██     ██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██ 
██      ██   ██ ███████ ██████      ██   ████ ███████  ██████    ████   ██ ██      ██ 
    ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
        -- stylua: ignore
        center = {
          { action = 'Telescope projects',                           desc = " Find projects",       icon = " ", key = "p" },
          { action = 'Telescope find_files',                           desc = " Find File",       icon = " ", key = "f" },
          { action = "ene | startinsert",                              desc = " New File",        icon = " ", key = "n" },
          { action = 'Telescope oldfiles',                 desc = " Recent Files",    icon = " ", key = "r" },
          { action = 'Telescope live_grep',                desc = " Find Text",       icon = " ", key = "g" },
          { action = 'lua LazyVim.pick.config_files()()',              desc = " Config",          icon = " ", key = "c" },
          { action = 'lua require("persistence").load()',              desc = " Restore Session", icon = " ", key = "s" },
          { action = "LazyExtras",                                     desc = " Lazy Extras",     icon = " ", key = "x" },
          { action = "Lazy",                                           desc = " Lazy",            icon = "󰒲 ", key = "l" },
          { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit",            icon = " ", key = "q" },
        },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- open dashboard after closing lazy
      if vim.o.filetype == "lazy" then
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(vim.api.nvim_get_current_win()),
          once = true,
          callback = function()
            vim.schedule(function()
              vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
            end)
          end,
        })
      end

      return opts
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    -- keys = {},
    -- change some options
    opts = {
      defaults = {
        wrap_results = true,
      },
    },
  },

  {
    "echasnovski/mini-git",
    -- event = "BufEnter",
    version = false,
    main = "mini.git",
    config = function()
      require("mini.git").setup()
    end,
  },
  -- {
  --   "kazhala/close-buffers.nvim",
  -- },
  -- {
  --   "rcarriga/nvim-notify",
  -- },
  {
    "stevearc/conform.nvim",
    event = "BufEnter",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
      },
    },
  },
  -- {
  --   "danymat/neogen",
  --   dependencies = "nvim-treesitter/nvim-treesitter",
  --   config = true,
  --   -- Uncomment next line if you want to follow only stable versions
  --   version = "*",
  --   opts = function()
  --     return {
  --       snippet_engine = "luasnip",
  --     }
  --   end,
  -- },
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- branch = "v3.x",
    -- version = "3.22",
    dependencies = { "MunifTanjim/nui.nvim", "s1n7ax/nvim-window-picker" },
    cmd = "Neotree",
    init = function()
      vim.g.neo_tree_remove_legacy_commands = true
    end,
    opts = function()
      -- local utils = require "base.utils"
      -- local get_icon = utils.get_icon
      return {
        auto_clean_after_session_restore = true,
        close_if_last_window = true,
        buffers = {
          show_unloaded = true,
        },
        sources = { "filesystem", "buffers", "git_status" },
        source_selector = {
          winbar = true,
          content_layout = "center",
          -- sources = {
          --   {
          --     source = "filesystem",
          --     display_name = get_icon("FolderClosed", 1, true) .. "File",
          --   },
          --   {
          --     source = "buffers",
          --     display_name = get_icon("DefaultFile", 1, true) .. "Bufs",
          --   },
          --   {
          --     source = "git_status",
          --     display_name = get_icon("Git", 1, true) .. "Git",
          --   },
          --   {
          --     source = "diagnostics",
          --     display_name = get_icon("Diagnostic", 1, true) .. "Diagnostic",
          --   },
          -- },
        },
        default_component_configs = {
          indent = { padding = 0 },
          git_status = {},
        },
        -- A command is a function that we can assign to a mapping (below)
        commands = {
          system_open = function(state)
            system_open(state.tree:get_node():get_id())
          end,
          parent_or_close = function(state)
            local node = state.tree:get_node()
            if (node.type == "directory" or node:has_children()) and node:is_expanded() then
              state.commands.toggle_node(state)
            else
              require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
            end
          end,
          child_or_open = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" or node:has_children() then
              if not node:is_expanded() then -- if unexpanded, expand
                state.commands.toggle_node(state)
              else -- if expanded and has children, seleect the next child
                require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
              end
            else -- if not a directory just open it
              state.commands.open(state)
            end
          end,
          copy_selector = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local filename = node.name
            local modify = vim.fn.fnamemodify

            local results = {
              e = { val = modify(filename, ":e"), msg = "Extension only" },
              f = { val = filename, msg = "Filename" },
              F = {
                val = modify(filename, ":r"),
                msg = "Filename w/o extension",
              },
              h = {
                val = modify(filepath, ":~"),
                msg = "Path relative to Home",
              },
              p = {
                val = modify(filepath, ":."),
                msg = "Path relative to CWD",
              },
              P = { val = filepath, msg = "Absolute path" },
            }

            local messages = {
              { "\nChoose to copy to clipboard:\n", "Normal" },
            }
            for i, result in pairs(results) do
              if result.val and result.val ~= "" then
                vim.list_extend(messages, {
                  { ("%s."):format(i), "Identifier" },
                  { (" %s: "):format(result.msg) },
                  { result.val, "String" },
                  { "\n" },
                })
              end
            end
            vim.api.nvim_echo(messages, false, {})
            local result = results[vim.fn.getcharstr()]
            if result and result.val and result.val ~= "" then
              vim.notify("Copied: " .. result.val)
              vim.fn.setreg("+", result.val)
            end
          end,
          find_in_dir = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require("telescope.builtin").find_files({
              cwd = node.type == "directory" and path or vim.fn.fnamemodify(path, ":h"),
            })
          end,
        },
        window = {
          width = 30,
          mappings = {
            ["I"] = "fuzzy_finder",
            ["/"] = false, -- disable space until we figure out which-key disabling
            ["<space>"] = false, -- disable space until we figure out which-key disabling
            ["[b"] = "prev_source",
            ["]b"] = "next_source",
            F = "find_in_dir" or nil,
            O = "system_open",
            Y = "copy_selector",
            h = "parent_or_close",
            l = "child_or_open",
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = false,
          },
          hijack_netrw_behavior = "open_current",
          use_libuv_file_watcher = false,
        },
        event_handlers = {
          {
            event = "neo_tree_buffer_enter",
            handler = function(_)
              vim.opt_local.signcolumn = "auto"
            end,
          },
        },
      }
    end,
  },
  -- {
  --   "smoka7/hop.nvim",
  --   -- cmd = { "HopWord" },
  --   opts = { keys = "etovxqpdygfblzhckisuran" },
  --   config = function(_, opts)
  --     require("hop").setup(opts)
  --   end,
  -- },
  -- { "nvim-pack/nvim-spectre" },
  -- {
  --   "noib3/nvim-oxi",
  --   config = function()
  --     -- require("nvim-oxi").setup()
  --   end,
  -- },
  -- { "vim-scripts/DoxygenToolkit.vim", cmd = "Dox" },
  -- {
  --   "shumphrey/fugitive-gitlab.vim",
  --   config = function()
  --     vim.cmd([[
  --   let g:fugitive_gitlab_domains = ['https://gitlab.onera.net/']
  --   ]])
  --   end,
  -- },
  -- { "tpope/vim-fugitive" },
  --supportera bientot gitlab pour les issues et MR
  -- {
  --   "pwntester/octo.nvim",
  --   -- dependencies = {
  --   --   -- "nvim-lua/plenary.nvim",
  --   --   -- "nvim-telescope/telescope.nvim",
  --   --   -- "nvim-tree/nvim-web-devicons",
  --   -- },
  --   config = function()
  --     require("octo").setup()
  --   end,
  -- },
  {
    "Shatur/neovim-tasks",
    -- ft = { "cpp", "c", "txt" }, -- charger uniquement pour les fichiers C++ ou C
    event = "BufEnter",
    config = function()
      local Path = require("plenary.path")
      require("tasks").setup({
        default_params = {
          -- Default module parameters with which `neovim.json` will be created.
          cmake = {
            cmd = "cmake", -- CMake executable to use, can be changed using `:Task set_module_param cmake cmd`.
            build_dir = tostring(Path:new("{cwd}", "build")), -- Build directory. The expressions `{cwd}`, `{os}` and `{build_type}` will be expanded with the corresponding text values. Could be a function that return the path to the build directory.
            build_type = "Debug", -- Build type, can be changed using `:Task set_module_param cmake build_type`.
            dap_name = "lldb", -- DAP configuration name from `require('dap').configurations`. If there is no such configuration, a new one with this name as `type` will be created.
            args = { -- Task default arguments.
              configure = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
            },
          },
        },
        save_before_run = false, -- If true, all files will be saved before executing a task.
        params_file = "neovim.json", -- JSON file to store module and task parameters.
        quickfix = {
          pos = "botright", -- Default quickfix position.
          height = 12, -- Default height.
        },
        dap_open_command = function()
          return require("dap").repl.open()
        end, --
      })
    end,
  },
  -- {
  -- "wellle/context.vim",
  --     config = function( )
  --   vim.cmd("let g:context_enabled = 1")
  --     end,
  --   },
  -- {
  --   -- big lag with this plugin
  --   "nvim-treesitter/nvim-treesitter-context",
  --   config = function()
  --     require("plugins.config.nvim-treesitter-context")
  --   end,
  -- },
  -- {
  --   "skywind3000/asyncrun.vim",
  --   enabled = true,
  -- },
  -- {
  --   "HiPhish/rainbow-delimiters.nvim",
  --   config = function()
  --     require("plugins.config.nvim-ts-rainbow")
  --   end,
  -- },
  {
    "uga-rosa/translate.nvim",
    event = "BufEnter",
    config = function()
      require("translate").setup({})
    end,
  },
  -- { "p00f/clangd_extensions.nvim" },
  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = function()
      require("goto-preview").setup({})
    end,
  },
  -- {
  --   "Civitasv/cmake-tools.nvim",
  --   enabled = true,
  --   -- event = "VeryLazy",
  --   config = function()
  --     -- require("plugins.configs.cmakeTool")
  --   end,
  -- },
  {
    "nvim-telekasten/telekasten.nvim",
    -- event = "VeryLazy",
    enabled = true,
    config = function()
      require("plugins.config.telekasten")
    end,
    cmd = "Telekasten",
  },
  -- {
  --   "NeogitOrg/neogit",
  --   -- event = "VeryLazy",
  --   -- requires = "nvim-lua/plenary.nvim",
  --   config = function()
  --     require("plugins.config.neogit")
  --   end,
  --   cmd = "Neogit",
  -- },
  -- {
  --   "kylechui/nvim-surround",
  --   version = "*", -- Use for stability; omit to use `main` branch for the latest features
  --   -- event = "VeryLazy",
  --   config = function()
  --     require("nvim-surround").setup({
  --       -- Configuration here, or leave empty to use defaults
  --     })
  --   end,
  -- },
  -- {
  --   "simnalamburt/vim-mundo",
  --   event = "BufEnter",
  -- },
  -- {
  --   "rhysd/git-messenger.vim",
  --   event = "VeryLazy",
  --   config = function()
  --     -- vim.api.nvim_command 'let g:git_messenger_include_diff="current"'
  --     --[[ vim.api.nvim_command("let g:git_messenger_floating_win_opts = { 'border': 'single' }") ]]
  --     --[[ vim.api.nvim_command("let g:git_messenger_no_default_mappings=v:true") ]]
  --     vim.api.nvim_command("let g:git_messenger_always_into_popup=v:true")
  --   end,
  -- },
  -- { "akinsho/git-conflict.nvim", version = "*", config = true }, -- fait grave bug
  {
    "tanvirtin/vgit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("vgit").setup()
    end,
    opts = {
      settings = {
        scene = {
          keymaps = {
            quit = "q",
          },
        },
      },
    },
  },
  {
    "aaronhallaert/advanced-git-search.nvim",
    config = function()
      -- optional: setup telescope before loading the extension
      require("telescope").setup({
        -- move this to the place where you call the telescope setup function
        extensions = {
          advanced_git_search = {
            -- See Config
          },
        },
      })

      require("telescope").load_extension("advanced_git_search")
    end,
    dependencies = {
      --- See dependencies
    },
  },
  {
    "niuiic/git-log.nvim",
    dependencies = {
      "niuiic/core.nvim",
    },
    config = function()
      require("git-log").setup()
    end,
  },
  -- {
  --   "xolox/vim-colorscheme-switcher",
  --   dependencies = { "xolox/vim-misc" },
  --   event = "VeryLazy",
  -- },
  -- {
  -- 	"chrisgrieser/nvim-tinygit",
  -- 	ft = { "git_rebase", "gitcommit" }, -- so ftplugins are loaded
  -- 	dependencies = {
  -- 		"stevearc/dressing.nvim",
  -- 		"nvim-telescope/telescope.nvim", -- either telescope or fzf-lua
  -- 		-- "ibhagwan/fzf-lua",
  -- 		"rcarriga/nvim-notify", -- optional, but will lack some features without it
  -- 	},
  -- },
  {
    "rhysd/devdocs.vim",
    ft = { "cpp", "c" }, -- charger uniquement pour les fichiers C++ ou C
    config = function()
      vim.cmd([[let g:devdocs_filetype_map = {'c': 'c'} ]])
    end,
  },
  -- {
  --   "mzlogin/vim-markdown-toc",
  --   ft = { "md" },
  -- },
  {
    "hedyhli/markdown-toc.nvim",
    ft = "markdown", -- Lazy load on markdown filetype
    cmd = { "Mtoc" }, -- Or, lazy load on "Mtoc" command
    opts = {
      -- Your configuration here (optional)
    },
  },
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   event = "BufEnter",
  --   build = "cd app && npm install",
  --   ft = "markdown",
  --   config = function()
  --     vim.g.mkdp_auto_start = 1
  --   end,
  -- },
  {
    "sindrets/diffview.nvim",
    event = "BufEnter",
    -- event = "BufRead",
  },
  -- {
  --   "folke/trouble.nvim",
  --   -- dependencies = { "nvim-tree/nvim-web-devicons" },
  --   opts = {
  --
  --     -- your configuration comes here
  --     -- or leave it empty to use the default settings
  --     -- refer to the configuration section below
  --   },
  -- },
  -- { "lunarvim/colorschemes" },
  -- {
  --   "stevearc/dressing.nvim",
  --   config = function()
  --     require("dressing").setup({
  --       input = { enabled = false },
  --     })
  --   end,
  -- },

  -- {
  --     "nvim-neo-tree/neo-tree.nvim",
  --     branch = "v3.x",
  --     dependencies = {
  --       "nvim-lua/plenary.nvim",
  --       "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
  --       "MunifTanjim/nui.nvim",
  --       -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  --     }
  -- },
  {
    "numtostr/FTerm.nvim",
    event = "BufEnter",
    config = function()
      require("plugins.config.fterm")
    end,
  },
  {
    "cshuaimin/ssr.nvim",
    keys = {
      {
        "<leader>se",
        ":lua require('ssr').open()<cr>",
      },
    },

    opts = {
      border = "rounded",
      min_width = 50,
      min_height = 5,
      max_width = 120,
      max_height = 25,
      adjust_window = true,
      keymaps = {
        close = "q",
        next_match = "n",
        prev_match = "N",
        replace_confirm = "<cr>",
        replace_all = "<leader><cr>",
      },
    },
  },
  {
    "linrongbin16/colorbox.nvim",

    -- don't lazy load
    lazy = false,

    -- load with highest priority
    priority = 1000,

    -- required by 'mcchrish/zenbones.nvim'
    dependencies = "rktjmp/lush.nvim",

    build = function()
      require("colorbox").update()
    end,
    config = function()
      require("colorbox").setup({
        filter = false,
        background = nil,
        policy = "shuffle",
        timing = "startup",
      })
    end,
  },
  {
    "max397574/better-escape.nvim",
    event = "BufEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
  -- {
  --   "drybalka/clean.nvim",
  --   config = function()
  --     -- require("clean").clean_keymap()
  --     require("clean").clean_plugins()
  --   end,
  -- },
  -- {
  --   "cbochs/portal.nvim",
  --   -- Optional dependencies
  --   dependencies = {
  --     "cbochs/grapple.nvim",
  --     "ThePrimeagen/harpoon",
  --   },
  -- },
  {
    "mpas/marp-nvim",
    ft = { "md" },
    config = function()
      require("marp").setup({
        port = 8080,
        wait_for_response_timeout = 30,
        wait_for_response_delay = 1,
      })
    end,
  },
  {
    "SGauvin/ctest-telescope.nvim",
    ft = { "cpp", "c", "txt" },
    opts = {
      -- Path to the ctest executable
      ctest_path = "ctest",
      -- Folder where your compiled executables will be found
      build_folder = "build",
      dap_config = {
        type = "codelldb",
        request = "launch",
        stopAtEntry = true,
        expressions = "native",
        -- setupCommands = {
        -- 	{
        -- 		text = "-enable-pretty-printing",
        -- 		description = "Enable pretty printing",
        -- 		ignoreFailures = false,
        -- 	},
        -- },
      },
      extra_ctest_args = { "-C", "Debug" },
    },
    config = function()
      require("ctest-telescope").setup({
        dap_config = {
          type = "codelldb",
          request = "launch",
          stopAtEntry = true,
          -- setupCommands = {
          -- 	{
          -- 		text = "-enable-pretty-printing",
          -- 		description = "Enable pretty printing",
          -- 		ignoreFailures = false,
          -- 	},
          -- },
          expressions = "native",
        },
        extra_ctest_args = { "-C", "Debug" },
      })
    end,
  },
  -- {
  --   "nvim-telescope/telescope-project.nvim",
  --   config = function()
  --     require("telescope").load_extension("project")
  --   end,
  -- },
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
      require("telescope").load_extension("projects")
    end,
  },
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>", false },
    },
  },
  {
    "tiagovla/scope.nvim",
    lazy = false,
    config = function()
      require("scope").setup({})
      require("telescope").load_extension("scope")
    end,
    keys = {
      { "<leader>ba", "<cmd>Telescope scope buffers<cr>", desc = "Telescope scope buffers" },
    },
  },
  -- {
  --   "kdheepak/lazygit.nvim",
  --   lazy = true,
  --   cmd = {
  --     "LazyGit",
  --     "LazyGitConfig",
  --     "LazyGitCurrentFile",
  --     "LazyGitFilter",
  --     "LazyGitFilterCurrentFile",
  --   },
  --   -- optional for floating window border decoration
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   -- setting the keybinding for LazyGit with 'keys' is recommended in
  --   -- order to load the plugin when the command is run for the first time
  --   keys = {
  --     { "<leader>gp", "<cmd>LazyGit<cr>", desc = "LazyGit plugin" },
  --   },
  -- },
  -- { -- This plugin
  --   "Zeioth/compiler.nvim",
  --   ft = { "py", "c", "cpp" },
  --   cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
  --   dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
  --   opts = {},
  -- },
  -- { -- The task runner we use
  --   "stevearc/overseer.nvim",
  --   ft = { "py", "c", "cpp" },
  --   commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
  --   cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
  --   opts = {
  --     task_list = {
  --       direction = "bottom",
  --       min_height = 25,
  --       max_height = 25,
  --       default_detail = 1,
  --     },
  --   },
  -- },
  {
    "nvim-neotest/neotest",
    ft = { "py", "c", "cpp" },
    opts = {
      adapters = {
        ["neotest-python"] = {
          -- Here you can specify the settings for the adapter, i.e.
          -- runner = "pytest",
          python = "python",
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      -- Ensure C/C++ debugger is installed
      "williamboman/mason.nvim",
      optional = true,
      opts = { ensure_installed = { "codelldb" } },
    },
    -- config = function()
    -- local dap = require("dap")
    -- dap.defaults.fallback.terminal_win_cmd = "tabnew"
    -- dap.defaults.python.terminal_win_cmd = "belowright new"
    -- dap.defaults.fallback.force_external_terminal = true
    -- end,
    opts = function()
      local dap = require("dap")
      if not dap.adapters["codelldb"] then
        require("dap").adapters["codelldb"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "codelldb",
            args = {
              "--port",
              "${port}",
            },
            expressions = "native",
          },
        }
      end
      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            type = "codelldb",
            request = "launch",
            name = "Launch file",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            expressions = "native",
          },
          {
            type = "codelldb",
            request = "attach",
            name = "Attach to process",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            expressions = "native",
          },
        }
      end
    end,
  },
  -- { "echasnovski/mini.pairs", enabled = false },
  -- {
  --   "windwp/nvim-autopairs",
  --   event = "InsertEnter",
  --   config = true,
  --   opts = {
  --     active = true,
  --     on_config_done = nil,
  --     ---@usage  modifies the function or method delimiter by filetypes
  --     map_char = {
  --       all = "(",
  --       tex = "{",
  --     },
  --     ---@usage check bracket in same line
  --     enable_check_bracket_line = false,
  --     ---@usage check treesitter
  --     check_ts = true,
  --     ts_config = {
  --       lua = { "string", "source" },
  --       javascript = { "string", "template_string" },
  --       java = false,
  --     },
  --     disable_filetype = { "TelescopePrompt", "spectre_panel" },
  --     ---@usage disable when recording or executing a macro
  --     disable_in_macro = false,
  --     ---@usage disable  when insert after visual block mode
  --     disable_in_visualblock = false,
  --     disable_in_replace_mode = true,
  --     ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
  --     enable_moveright = true,
  --     ---@usage add bracket pairs after quote
  --     enable_afterquote = true,
  --     ---@usage trigger abbreviation
  --     enable_abbr = false,
  --     ---@usage switch for basic rule break undo sequence
  --     break_undo = true,
  --     map_cr = true,
  --     ---@usage map the <BS> key
  --     map_bs = true,
  --     ---@usage map <c-w> to delete a pair if possible
  --     map_c_w = false,
  --     ---@usage Map the <C-h> key to delete a pair
  --     map_c_h = false,
  --     ---@usage  change default fast_wrap
  --     fast_wrap = {
  --       map = "<A-e>",
  --       chars = { "{", "[", "(", '"', "'" },
  --       pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
  --       offset = 0, -- Offset from pattern match
  --       end_key = "$",
  --       keys = "qwertyuiopzxcvbnmasdfghjkl",
  --       check_comma = true,
  --       highlight = "Search",
  --       highlight_grey = "Comment",
  --     },
  --   },
  --   -- use opts = {} for passing setup options
  --   -- this is equivalent to setup({}) function
  -- },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tinymist = {
          settings = {
            exportPdf = "onType",
            outputPath = "$root/target/$dir/$name",
          },
        },
        ltex = {
          settings = {
            ltex = {
              language = "auto",
            },
          },
        },
      },
    },
  },
  {
    "chomosuke/typst-preview.nvim",
    lazy = false, -- or ft = 'typst'
    version = "1.*",
    build = function()
      require("typst-preview").update()
    end,

    config = function()
      require("typst-preview").setup({
        -- Setting this true will enable printing debug information with print()
        debug = false,

        -- Custom format string to open the output link provided with %s
        -- open_cmd = "firefox %s -P typst-preview --class typst-preview",
        -- open_cmd = nil,

        -- Setting this to 'always' will invert black and white in the preview
        -- Setting this to 'auto' will invert depending if the browser has enable
        -- dark mode
        -- Setting this to '{"rest": "<option>","image": "<option>"}' will apply
        -- your choice of color inversion to images and everything else
        -- separately.
        invert_colors = "never",

        -- Whether the preview will follow the cursor in the source file
        follow_cursor = true,

        -- Provide the path to binaries for dependencies.
        -- Setting this will skip the download of the binary by the plugin.
        -- Warning: Be aware that your version might be older than the one
        -- required.
        dependencies_bin = {
          ["tinymist"] = nil,
          ["websocat"] = nil,
        },

        -- A list of extra arguments (or nil) to be passed to previewer.
        -- For example, extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
        extra_args = nil,

        -- This function will be called to determine the root of the typst project
        get_root = function(path_of_main_file)
          return vim.fn.fnamemodify(path_of_main_file, ":p:h")
        end,

        -- This function will be called to determine the main file of the typst
        -- project.
        get_main_file = function(path_of_buffer)
          return path_of_buffer
        end,
      })
    end,
  },
  {
    -- dd to balckhole
    "gbprod/cutlass.nvim",
    opts = {
      cut_key = "c",
      -- your configuration comes here
      -- or don't set opts to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    keys = {
      {
        "<A-g>",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = " rip substitute",
      },
    },
  },
}
