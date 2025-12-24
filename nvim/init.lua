-- ============================================================================
-- Neovim config (modern Neovim 0.11+ style)
-- - lazy.nvim
-- - native LSP config/enable (no require('lspconfig') usage)
-- - new nvim-treesitter API (rewrite)
-- ============================================================================
--


-- Make Mason use public npm registry (without touching your shell/company ~/.npmrc)
local mason_npmrc = vim.fn.stdpath("config") .. "/npmrc.mason"

if vim.fn.filereadable(mason_npmrc) == 0 then
  vim.fn.writefile({
    "registry=https://registry.npmjs.org/",
    "always-auth=false",
  }, mason_npmrc)
end

-- npm reads config from env vars (case-insensitive)
vim.env.NPM_CONFIG_USERCONFIG = mason_npmrc
vim.env.npm_config_userconfig = mason_npmrc
vim.env.NPM_CONFIG_REGISTRY = "https://registry.npmjs.org/"
vim.env.npm_config_registry = "https://registry.npmjs.org/"
vim.env.NPM_CONFIG_ALWAYS_AUTH = "false"
vim.env.npm_config_always_auth = "false"

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Disable netrw (recommended for nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- General settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.showmode = false
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.hidden = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ============================================================================
-- lazy.nvim bootstrap
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugins
-- ============================================================================
require("lazy").setup({
  -- Theme
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({ style = "darker" })
      require("onedark").load()
    end,
  },

  -- File explorer, commenting this as i think i am not gonna need it 
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>es", "<cmd>NvimTreeToggle<cr>", { silent = true, desc = "Explorer" })
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find by Grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })

      -- Git quick access with telescope
      vim.keymap.set("n", "<leader>gs", builtin.git_status,   { desc = "Git status (Telescope)" })
      vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits,  { desc = "Git commits (repo)" })
      vim.keymap.set("n", "<leader>gC", builtin.git_bcommits, { desc = "Git commits (current file)" })

      -- Go to ~ code with telescope
      vim.keymap.set("n","gd",require("telescope.builtin").lsp_definitions,{desc="LSP definitions (Telescope)"})
      vim.keymap.set("n","gD",require("telescope.builtin").lsp_type_definitions,{desc="LSP type definitions (Telescope)"})
      vim.keymap.set("n","gr",require("telescope.builtin").lsp_references,{desc="LSP references (Telescope)"})
      vim.keymap.set("n","gi",require("telescope.builtin").lsp_implementations,{desc="LSP implementations (Telescope)"})

    end,
  },

  -- LazyGit
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim" }, -- optional, but nice for floating window behavior
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>",            desc = "LazyGit" },
      { "<leader>gF", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (current file)" },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  },

  -- Treesitter (NEW API / rewrite)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- IMPORTANT: plugin says it doesn't support lazy-loading
    build = function()
      -- Avoid errors if TSUpdate isn't available yet
      pcall(vim.cmd, "TSUpdate")
    end,
    config = function()
      local ts = require("nvim-treesitter")

      -- Setup parser/query install location
      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      -- Install parsers you care about (idempotent)
      ts.install({
        "lua", "vim", "vimdoc", "query",
        "javascript", "typescript",
        "json", "bash",
        "markdown", "markdown_inline",
        "html", "css",
        "python", "go", "rust",
      })

      -- Enable treesitter highlighting (native)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- LSP + completion
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "mason-org/mason-lspconfig.nvim",

      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",

      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("mason").setup()

      -- Install servers via Mason
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls", -- replaces tsserver
          "pyright",
          "gopls",
          "rust_analyzer",
        },
        automatic_installation = true,
        automatic_enable = false, -- we enable explicitly below (predictable)
      })

      -- Capabilities for nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Neovim 0.11+ native config/enable
      local servers = { "lua_ls", "ts_ls", "pyright", "gopls", "rust_analyzer" }

      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities })
      end

      vim.lsp.enable(servers)

      -- Diagnostics UI
      vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Diag float" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diag" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diag" })
      vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, { desc = "Diag list" })

      -- Buffer-local LSP mappings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          -- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })

      -- nvim-cmp
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- cmdline completion (optional but nice)
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },

  -- Git signs (gitsigns)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Don’t spam blame all the time; toggle it when needed
      current_line_blame = false,
      current_line_blame_opts = {
        delay = 800,
        use_focus = true,
      },

      -- Optional: show different signs for staged changes
      signcolumn = true,
      -- staged signs are supported by gitsigns; if you like them, keep this on
      -- (some people prefer minimalism and turn it off)
      -- show_staged = true,

      -- Good safety: disable in huge files (adjust to taste)
      max_file_length = 40000,

      on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Jump between hunks (like ]d/[d but for git changes)
        map("n", "]c", function()
          if vim.wo.diff then return vim.cmd.normal({ "]c", bang = true }) end
          gs.nav_hunk("next")
        end, "Next hunk")

        map("n", "[c", function()
          if vim.wo.diff then return vim.cmd.normal({ "[c", bang = true }) end
          gs.nav_hunk("prev")
        end, "Prev hunk")

        -- Preview / diff
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>ghi", gs.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>ghd", gs.diffthis, "Diff this file")

        -- Stage/reset like `git add -p`
        map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")

        -- Visual-mode stage/reset selection
        map("v", "<leader>ghs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage selection")
        map("v", "<leader>ghr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset selection")

        -- Blame
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame line (full)")
        map("n", "<leader>ght", gs.toggle_current_line_blame, "Toggle line blame")

        -- Quickfix list of hunks (nice for reviewing all changes)
        map("n", "<leader>ghq", function()
          gs.setqflist("all")
        end, "Hunks -> quickfix")

        -- Text object (operate on a hunk)
        map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
      end,
    },
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Comment toggles
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup()
    end,
  },

  -- Toggleterm
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
      })
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Oil
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = false,
        view_options = { show_hidden = true },
      })

      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      -- Open Oil in a vertical split (nice for comparing/moving files)
      vim.keymap.set("n", "<leader>O", "<cmd>vsplit | Oil<CR>", { desc = "Oil (vsplit)" })
    end,
  },


  -- Comment toggles (context-aware for JSX/TSX)
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      local ok, ts_integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      require("Comment").setup({
        pre_hook = ok and ts_integration.create_pre_hook() or nil,
      })
    end,
  },
})

-- ============================================================================
-- Extra keymaps
-- ============================================================================
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { silent = true, desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = true, desc = "Quit" })
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<cr>", { silent = true, desc = "Clear search" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Down window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Up window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Right window" })

vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<cr>", { silent = true, desc = "Resize -height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<cr>", { silent = true, desc = "Resize +height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { silent = true, desc = "Resize -width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { silent = true, desc = "Resize +width" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { silent = true, desc = "Prev buffer" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "<leader>sv", function()
  local ft = vim.bo.filetype
  vim.cmd("vnew")
  vim.bo.swapfile = false
  vim.bo.bufhidden = "wipe"
  vim.bo.buftype = ""
  vim.cmd("setlocal filetype=" .. ft)
end, { desc = "Scratch vsplit (match filetype)" })

vim.keymap.set("n", "<leader>bb", require("telescope.builtin").buffers, {
  desc = "Open recent buffers",
})

vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>bd", ":bp | bd #<CR>", {
  silent = true,
  desc = "Delete buffer (no plugin)",
})

vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%") -- path relative to cwd
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy relative file path" })
