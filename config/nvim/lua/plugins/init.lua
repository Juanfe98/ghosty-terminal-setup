return {
	-- Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- matches Ghostty Catppuccin Mocha
				transparent_background = true,
				styles = {
					comments = { "italic" },
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- File explorer, commenting this as i think i am not gonna need it
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				-- Show only the project/root folder name at the top instead of the full ~/... path.
				renderer = {
					root_folder_label = function(path)
						return "󰉋 " .. vim.fn.fnamemodify(path, ":t")
					end,
				},
				-- When the tree is open, keep the current file highlighted as you move around.
				update_focused_file = {
					enable = true,
					update_root = false,
				},
			})
			vim.keymap.set("n", "<leader>tt", "<cmd>NvimTreeToggle<cr>", { silent = true, desc = "Explorer" })
			vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFindFile<cr>", { silent = true, desc = "Explorer: reveal current file" })
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "v0.2.0",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		config = function()
			local function project_relative_path(_, path)
				local cwd = vim.uv.cwd() or vim.fn.getcwd()
				local root = vim.fs.root(cwd, {
					".git",
					"package.json",
					"pnpm-workspace.yaml",
					"pyproject.toml",
					"Cargo.toml",
					"go.mod",
				}) or cwd

				local full_path = path
				if not full_path:match("^/") then
					full_path = cwd .. "/" .. full_path
				end

				full_path = vim.fn.fnamemodify(full_path, ":p")
				root = vim.fn.fnamemodify(root, ":p")

				if full_path:sub(1, #root) == root then
					return full_path:sub(#root + 1)
				end

				return vim.fn.fnamemodify(path, ":.")
			end

			local function filename_first_project_relative_path(opts, path)
				local relative_path = project_relative_path(opts, path)
				local filename = vim.fn.fnamemodify(relative_path, ":t")
				local directory = vim.fn.fnamemodify(relative_path, ":h")

				if directory == "." or directory == "" then
					return filename
				end

				return filename .. "  " .. directory .. "/"
			end

			local live_grep_args_actions = require("telescope-live-grep-args.actions")

			require("telescope").setup({
				defaults = {
					-- Default layout for every Telescope picker, including LSP references (`gr`).
					layout_strategy = "horizontal",
					layout_config = {
						width = 0.95,
						height = 0.85,
						preview_width = 0.5,
					},
					preview = {
						-- Start with the preview hidden so long file paths/results are easier to read.
						-- Press <C-p> inside Telescope to toggle it back on.
						hide_on_startup = true,
					},
					mappings = {
						i = {
							["<C-p>"] = require("telescope.actions.layout").toggle_preview,
						},
						n = {
							["<C-p>"] = require("telescope.actions.layout").toggle_preview,
						},
					},
					-- Show filename first, then project-relative directory, so monorepo paths do not hide filenames.
					path_display = filename_first_project_relative_path,
				},
				extensions = {
					live_grep_args = {
						-- Make `keyword -g "*.tsx"` work naturally.
						-- If this is true, the whole prompt becomes the search text unless you quote manually.
						auto_quoting = false,
						mappings = {
							i = {
								["<C-k>"] = live_grep_args_actions.quote_prompt(),
								["<C-i>"] = live_grep_args_actions.quote_prompt({ postfix = " --iglob " }),
								["<C-space>"] = live_grep_args_actions.to_fuzzy_refine,
							},
						},
					},
				},
			})
			require("telescope").load_extension("live_grep_args")
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files()
			end, { desc = "Find Files; <C-p> toggles preview" })
			vim.keymap.set("n", "<leader>fH", function()
				builtin.find_files({ cwd = vim.fn.expand("~") })
			end, { desc = "Find Files from Home" })
			vim.keymap.set("n", "<leader>fg", function()
				require("telescope").extensions.live_grep_args.live_grep_args()
			end, { desc = "Find by Grep with filters" })
			vim.keymap.set("n", "<leader>fr", function()
				require("telescope.builtin").oldfiles({ only_cwd = true })
			end, { desc = "Recent files (cwd)" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })

			local function get_github_repo_context(callback)
				vim.system({ "git", "remote", "get-url", "origin" }, { text = true }, function(remote_result)
					local remote = vim.trim(remote_result.stdout or "")
					local host, repo = remote:match("^https?://([^/]+)/(.+)%.git$")
					if not host then
						host, repo = remote:match("^https?://([^/]+)/(.+)$")
					end
					if not host then
						host, repo = remote:match("^git@([^:]+):(.+)%.git$")
					end
					if not host then
						host, repo = remote:match("^git@([^:]+):(.+)$")
					end
					if not host then
						host, repo = remote:match("^ssh://git@([^/]+)/(.+)%.git$")
					end
					if not host then
						host, repo = remote:match("^ssh://git@([^/]+)/(.+)$")
					end

					callback(host, repo, remote)
				end)
			end

			local function open_commit_on_github(sha)
				sha = vim.trim(sha or "")
				if sha == "" then
					vim.notify("No commit SHA found", vim.log.levels.ERROR)
					return
				end

				vim.system({ "git", "rev-parse", sha }, { text = true }, function(rev)
					if rev.code ~= 0 then
						vim.schedule(function()
							vim.notify("Could not resolve commit: " .. sha, vim.log.levels.ERROR)
						end)
						return
					end

					local full_sha = vim.trim(rev.stdout or sha)
					get_github_repo_context(function(host, repo, remote)
						vim.schedule(function()
							if not host or not repo then
								vim.notify("Could not parse GitHub remote origin: " .. remote, vim.log.levels.ERROR)
								return
							end

							local url = "https://" .. host .. "/" .. repo .. "/commit/" .. full_sha
							vim.fn.setreg("+", url)
							vim.notify("Opening commit and copied URL:\n" .. url)

							if vim.ui.open then
								vim.ui.open(url)
							else
								vim.fn.jobstart({ "open", url }, { detach = true })
							end
						end)
					end)
				end)
			end

			local function selected_commit_sha(entry)
				if not entry then
					return nil
				end

				local candidates = { entry.value, entry.ordinal, entry.display }
				for _, candidate in ipairs(candidates) do
					if type(candidate) == "string" then
						local sha = candidate:match("%f[%x](%x%x%x%x%x%x%x+)%f[^%x]")
						if sha then
							return sha
						end
					elseif type(candidate) == "table" then
						for _, value in pairs(candidate) do
							if type(value) == "string" then
								local sha = value:match("%f[%x](%x%x%x%x%x%x%x+)%f[^%x]")
								if sha then
									return sha
								end
							end
						end
					end
				end
			end

			local function git_bcommits_with_commit_link_action()
				builtin.git_bcommits({
					attach_mappings = function(prompt_bufnr, map)
						local actions = require("telescope.actions")
						local action_state = require("telescope.actions.state")

						local open_commit = function()
							local sha = selected_commit_sha(action_state.get_selected_entry())
							actions.close(prompt_bufnr)
							open_commit_on_github(sha)
						end

						map("i", "<C-p>", open_commit)
						map("n", "<C-p>", open_commit)
						return true
					end,
				})
			end

			vim.api.nvim_create_user_command("GitCommitOpen", function(opts)
				open_commit_on_github(opts.args)
			end, { nargs = 1, desc = "Open a GitHub commit URL for a commit SHA" })

			-- Git quick access with telescope
			vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status (Telescope)" })
			vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
			vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits (repo)" })
			vim.keymap.set("n", "<leader>gC", git_bcommits_with_commit_link_action, { desc = "Git commits (current file); <C-p> opens commit" })

			-- Go to ~ code with telescope
			vim.keymap.set(
				"n",
				"gd",
				require("telescope.builtin").lsp_definitions,
				{ desc = "LSP definitions (Telescope)" }
			)
			vim.keymap.set(
				"n",
				"gD",
				require("telescope.builtin").lsp_type_definitions,
				{ desc = "LSP type definitions (Telescope)" }
			)
			vim.keymap.set(
				"n",
				"gr",
				require("telescope.builtin").lsp_references,
				{ desc = "LSP references (Telescope)" }
			)
			vim.keymap.set(
				"n",
				"gi",
				require("telescope.builtin").lsp_implementations,
				{ desc = "LSP implementations (Telescope)" }
			)
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
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
			{ "<leader>gF", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (current file)" },
		},
	},

	-- Git diff/review UI
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = {
			"DiffviewOpen",
			"DiffviewFileHistory",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
		},
		keys = {
			{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: working tree" },
			{ "<leader>gV", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diffview: compare with HEAD~1" },
			{ "<leader>gL", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: current file history" },
			{ "<leader>gA", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
			{ "<leader>gQ", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
			{ "<leader>gR", "<cmd>DiffviewRefresh<cr>", desc = "Diffview: refresh" },
		},
	},

	-- Harpoon: fast project file navigation
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>ma",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon: add file",
			},
			{
				"<leader>mm",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon: menu",
			},
			{
				"<leader>m1",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "Harpoon: file 1",
			},
			{
				"<leader>m2",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "Harpoon: file 2",
			},
			{
				"<leader>m3",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "Harpoon: file 3",
			},
			{
				"<leader>m4",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "Harpoon: file 4",
			},
			{
				"<leader>mp",
				function()
					require("harpoon"):list():prev()
				end,
				desc = "Harpoon: previous",
			},
			{
				"<leader>mn",
				function()
					require("harpoon"):list():next()
				end,
				desc = "Harpoon: next",
			},
		},
		config = function()
			require("harpoon"):setup()
		end,
	},

	-- Surround text objects: add/change/delete quotes, brackets, tags, etc.
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup()
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup()
		end,
	},

	-- Better folding UI/provider (LSP/Treesitter/indent)
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		event = "BufReadPost",
		config = function()
			-- Keep files unfolded by default, but enable powerful manual folding.
			-- No fold column: it shows noisy fold-level numbers/icons. Closed folds
			-- are still visible inline via nvim-ufo's folded-line virtual text.
			vim.o.foldcolumn = "0"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			require("ufo").setup({
				provider_selector = function(_, _, _)
					-- nvim-ufo supports only two providers: { main, fallback }.
					return { "lsp", "indent" }
				end,
			})

			vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
			vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds by level" })
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
				"lua",
				"vim",
				"vimdoc",
				"query",
				"javascript",
				"typescript",
				"tsx",
				"json",
				"bash",
				"markdown",
				"markdown_inline",
				"html",
				"css",
				"python",
				"go",
				"rust",
			})

			-- Enable treesitter highlighting (native)
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local bt = vim.bo[args.buf].buftype
					local ft = vim.bo[args.buf].filetype

					if bt ~= "" then
						return
					end

					if ft == "NvimTree" or ft == "oil" or ft == "help" or ft == "lazy" or ft == "mason" then
						return
					end

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
			vim.keymap.set("n", "<space>e", function()
				vim.diagnostic.open_float(nil, { border = "rounded", source = "if_many" })
			end, { desc = "Diag float" })
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
					vim.keymap.set({ "n", "v" }, "<space>f", function()
						require("conform").format({
							async = true,
							lsp_fallback = true,
						})
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
					if vim.wo.diff then
						return vim.cmd.normal({ "]c", bang = true })
					end
					gs.nav_hunk("next")
				end, "Next hunk")

				map("n", "[c", function()
					if vim.wo.diff then
						return vim.cmd.normal({ "[c", bang = true })
					end
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

	-- MarkdownPreview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 1
		end,
	},

	-- Render Markdown inline in Neovim
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "Markdown: toggle render" },
			{ "<leader>mP", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown: browser preview" },
		},
		config = function()
			require("render-markdown").setup({
				file_types = { "markdown" },
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.opt_local.conceallevel = 2
				end,
			})
		end,
	},

	-- Winbar breadcrumbs: file path + code symbols
	{
		"Bekaboo/dropbar.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("dropbar").setup()
		end,
	},

	-- Autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
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
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
			})

			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	},

	-- tiny-inline-diagnostic
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000, -- load early so highlights/preset feel consistent
		opts = {
			preset = "amongus",
			transparent_cursorline = true,
			transparent_bg = false,

			-- optional: avoid noise in UI buffers
			disabled_ft = {
				"TelescopePrompt",
				"lazy",
				"mason",
				"help",
				"NvimTree",
				"oil",
			},

			options = {
				-- keeps it snappy but not “twitchy”
				throttle = 20,

				-- wrap long messages nicely
				softwrap = 30,
				overflow = { mode = "wrap", padding = 0 },

				-- show LSP source only when it actually helps
				show_source = { enabled = true, if_many = true },

				-- multiline is nice for TS errors (stacky messages)
				multilines = {
					enabled = true,
					always_show = false,
					trim_whitespaces = true,
				},

				-- keep it clean while you type/select
				enable_on_insert = false,
				enable_on_select = false,

				-- prevents “inline + float” visual clutter
				override_open_float = true,

				-- related info can be useful, but keep it small
				show_related = { enabled = true, max_count = 2 },
			},
		},
		config = function(_, opts)
			require("tiny-inline-diagnostic").setup(opts)

			-- IMPORTANT: disable built-in virtual_text to avoid duplicates
			vim.diagnostic.config({
				virtual_text = false,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
			})

			-- handy toggles (pick whatever leader keys you like)
			vim.keymap.set("n", "<leader>dt", "<cmd>TinyInlineDiag toggle<cr>", { desc = "Toggle inline diagnostics" })
			vim.keymap.set("n", "<leader>de", "<cmd>TinyInlineDiag enable<cr>", { desc = "Enable inline diagnostics" })
			vim.keymap.set(
				"n",
				"<leader>dd",
				"<cmd>TinyInlineDiag disable<cr>",
				{ desc = "Disable inline diagnostics" }
			)
		end,
	},

	-- Diagnosis
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
			{ "<leader>xr", "<cmd>Trouble lsp_references toggle<cr>", desc = "References" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
		},
	},

	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			backends = { "lsp", "treesitter", "markdown", "man" },
			layout = {
				min_width = 28,
				default_direction = "prefer_right",
			},
			show_guides = true,
			filter_kind = false,
			attach_mode = "global",
			close_automatic_events = {},
		},
		keys = {
			{ "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Aerial toggle" },
			{ "]a", "<cmd>AerialNext<cr>", desc = "Next symbol" },
			{ "[a", "<cmd>AerialPrev<cr>", desc = "Prev symbol" },
		},
	},

	-- Todo comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			highlight = {
				comments_only = true,
				exclude = { "NvimTree", "oil", "lazy", "mason", "help", "TelescopePrompt" },
			},
		},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous todo comment",
			},
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search TODOs (Telescope)" },
			{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "TODOs (Trouble)" },
			{ "<leader>xT", "<cmd>TodoQuickFix<cr>", desc = "TODOs (Quickfix)" },
		},
	},

	-- Pretty floating notifications
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		opts = {
			timeout = 2500,
			render = "wrapped-default",
			stages = "fade_in_slide_out",
			top_down = true,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.4)
			end,
		},
		config = function(_, opts)
			local notify = require("notify")
			notify.setup(opts)

			-- Make Neovim + plugins use nvim-notify
			vim.notify = notify
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
			},
			format_on_save = {
				timeout_ms = 1000,
				lsp_fallback = true,
			},
		},
	},
}
