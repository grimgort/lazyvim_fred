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
    "nvim-telescope/telescope.nvim",
    keys = {},
    -- change some options
    opts = {
      defaults = {
        wrap_results = true,
      },
    },
  },

  {
    "echasnovski/mini-git",
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
  { "vim-scripts/DoxygenToolkit.vim" },
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
    config = function()
      require("translate").setup({})
    end,
  },
  -- { "p00f/clangd_extensions.nvim" },
  {
    "rmagatti/goto-preview",
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
  },
  {
    "NeogitOrg/neogit",
    -- event = "VeryLazy",
    -- requires = "nvim-lua/plenary.nvim",
    config = function()
      require("plugins.config.neogit")
    end,
  },
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
  -- {
  --   'tanvirtin/vgit.nvim',
  --   dependencies= {
  --     'nvim-lua/plenary.nvim'
  --   },
  -- 	config = function()
  -- require('vgit').setup()
  -- 		end,
  --   },
  -- {
  --   "aaronhallaert/advanced-git-search.nvim",
  --   config = function()
  --     -- optional: setup telescope before loading the extension
  --     require("telescope").setup({
  --       -- move this to the place where you call the telescope setup function
  --       extensions = {
  --         advanced_git_search = {
  --           -- See Config
  --         },
  --       },
  --     })
  --
  --     require("telescope").load_extension("advanced_git_search")
  --   end,
  --   dependencies = {
  --     --- See dependencies
  --   },
  -- },
  {
    "xolox/vim-colorscheme-switcher",
    dependencies = { "xolox/vim-misc" },
    event = "VeryLazy",
  },
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
    config = function()
      vim.cmd([[let g:devdocs_filetype_map = {'c': 'c'} ]])
    end,
  },
  {
    "mzlogin/vim-markdown-toc",
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
    config = function()
      require("plugins.config.fterm")
    end,
  },
  {
    "cshuaimin/ssr.nvim",
    -- module = "ssr",
    -- Calling setup is optional.
    config = function()
      require("ssr").setup({
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
      })
    end,
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
      require("colorbox").setup()
    end,
  },
  {
    "max397574/better-escape.nvim",
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
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>gp", "<cmd>LazyGit<cr>", desc = "LazyGit plugin" },
    },
  },
  { -- This plugin
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
    opts = {},
  },
  { -- The task runner we use
    "stevearc/overseer.nvim",
    commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
  },
  {
    "nvim-neotest/neotest",
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
          },
        }
      end
    end,
  },
}
