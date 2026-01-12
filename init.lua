-- basic settings

vim.cmd.colorscheme("catppuccin")

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.list = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.listchars = { trail = "_" }
vim.opt.hlsearch = false
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.colorcolumn = { 80, 120 }
vim.opt.showmode = false
vim.opt.undofile = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldopen = { "block", "mark", "percent", "quickfix", "search", "tag", "undo" }
vim.opt.foldenable = true
vim.opt.updatetime = 1000
if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
	vim.opt.grepformat:append("%f:%l:%c:%m")
end

vim.opt.inccommand = "split"

vim.g.have_nerd_font = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- keymaps

vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to pane below current pane" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to pane above current pane" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to pane to the left of current pane" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to pane to the right of current pane" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Go down half a page" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Go up half a page" })
vim.keymap.set("v", ">", ">gv", { desc = "Tabulate current selection forward" })
vim.keymap.set("v", "<", "<gv", { desc = "Tabulate current selection backward" })
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Go down one visual line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Go up one visual line" })
vim.keymap.set({ "n", "v" }, "0", "g0", { desc = "Go to the beginning of visual line" })
vim.keymap.set({ "n", "v" }, "$", "g$", { desc = "Go to the end of visual line" })
vim.keymap.set("n", "<A-j>", ":m+1<CR>", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m-2<CR>", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv", { desc = "Move selection up" })
vim.keymap.set("n", "<leader>xp", "yy2o<ESC>kpV:!/usr/bin/env bash<CR>")
vim.keymap.set("v", "<leader>xp", "y'<P'<O<ESC>'>o<ESC>:<C-u>'<,'>!/usr/bin/env bash<CR>")

--highlight ts

local folded_hl = vim.api.nvim_get_hl(0, { name = "Folded" })
folded_hl.bg = "#342E4F"
vim.api.nvim_set_hl(0, "Folded", folded_hl)

local vert_split_hl = vim.api.nvim_get_hl(0, { name = "VertSplit" })
vert_split_hl.bg = nil
vim.api.nvim_set_hl(0, "VertSplit", vert_split_hl)

-- treesitter

local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if ok_ts then
	ts_configs.setup({
		auto_install = true,
		ensure_installed = {
			"c",
			"cpp",
			"go",
			"haskell",
			"html",
			"javascript",
			"latex",
			"lua",
			"markdown",
			"typescript",
		},
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = {
			enable = true,
			disable = { "ruby" },
		},
		incremental_selection = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
			},
		},
	})
end

local ok_ctx, ts_context = pcall(require, "treesitter-context")
if ok_ctx then
	ts_context.setup({
		enable = false,
		max_lines = 0,
	})

	vim.keymap.set("n", "[c", function()
		require("treesitter-context").go_to_context(vim.v.count1)
	end)
end

--lsp

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("LspMappings", { clear = true }),
	callback = function(event)
		local function map(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
		end

		local builtin = require("telescope.builtin")

		map("gd", builtin.lsp_definitions, "Goto definitions")
		map("gr", builtin.lsp_references, "Goto references")
		map("gI", builtin.lsp_implementations, "Goto implementation")
		map("<leader>D", builtin.lsp_type_definitions, "Goto type definition")
		map("<leader>ds", builtin.lsp_document_symbols, "Document symbols")
		map("<leader>ws", builtin.lsp_workspace_symbols, "Workspace symbols")
		map("<leader>rn", vim.lsp.buf.rename, "Rename")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("<leader>oc", builtin.lsp_outgoing_calls, "Outgoing calls")
		map("<leader>ic", builtin.lsp_incoming_calls, "Incoming calls")

		map("K", vim.lsp.buf.hover, "Hover")
		map("gD", vim.lsp.buf.declaration, "Goto declaration")
		map("[d", vim.diagnostic.goto_prev, "Goto previous diagnostic")
		map("]d", vim.diagnostic.goto_next, "Goto next diagnostic")

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.server_capabilities.documentHighlightProvider then
			local highlight_augroup = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("LspHighlightDetach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "LspDocumentHighlight", buffer = event2.buf })
				end,
			})
		end

		if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "Toggle inlay hints")

			vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
		end

		vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
	end,
})

vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = {
		current_line = true,
		severity = { min = vim.diagnostic.severity.WARN },
	},
	signs = true,
	underline = true,
	severity_sort = true,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

local servers = {
	lua_ls = {
		settings = {
			Lua = {
				completion = { callSnippet = "Replace" },
				hint = { enable = true, setType = true },
			},
		},
	},

	ts_ls = {
		init_options = {
			preferences = {
				completeFunctionCalls = true,
			},
		},
		settings = {
			javascript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterHintsWhenArgumentMatchesName = true,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayVariableTypeHintsWhenTypeMatchesName = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterHintsWhenArgumentMatchesName = true,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayVariableTypeHintsWhenTypeMatchesName = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
			implicitProjectConfiguration = {
				checkJs = true,
				strictNullChecks = true,
			},
		},
	},

	rust_analyzer = { settings = { ["rust-analyzer"] = {} } },

	gopls = {
		settings = {
			gopls = {
				gofumpt = true,
				codelenses = {
					gc_details = false,
					generate = true,
					regenerate_cgo = true,
					run_govulncheck = true,
					test = true,
					tidy = true,
					upgrade_dependency = true,
					vendor = true,
				},
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
				analyses = {
					fieldalignment = true,
					nilness = true,
					unusedparams = true,
					unusedwrite = true,
					useany = true,
				},
				usePlaceholders = true,
				completeUnimported = true,
				staticcheck = true,
				directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
				semanticTokens = true,
			},
		},
	},

	clangd = {},

	nil_ls = {
		settings = {
			["nil"] = {
				formatting = { command = { "nixpkgs-fmt" } },
			},
		},
	},

	hls = { filetypes = { "haskell", "lhaskell", "cabal" } },

	texlab = {},
	racket_langserver = {
		cmd = { "racket-langserver-wrapper" },
	},
	glsl_analyzer = {},
}

for name, cfg in pairs(servers) do
	cfg = vim.tbl_deep_extend("force", { capabilities = capabilities }, cfg or {})
	vim.lsp.config(name, cfg)
end

vim.lsp.enable(vim.tbl_keys(servers))

--haskell

vim.api.nvim_create_autocmd("FileType", {
	pattern = "haskell",
	callback = function(ev)
		local ht = require("haskell-tools")

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = ev.buf, desc = desc })
		end

		map("n", "<leader>cl", vim.lsp.codelens.run, "Haskell: run code lenses")
		map("n", "<leader>hs", ht.hoogle.hoogle_signature, "Haskell: Hoogle signature")
		map("n", "<leader>ea", ht.lsp.buf_eval_all, "Haskell: eval all (HLS)")
		map("n", "<leader>rr", ht.repl.toggle, "Haskell: toggle REPL")

		map("n", "<leader>rf", function()
			ht.repl.toggle(vim.api.nvim_buf_get_name(ev.buf))
		end, "Haskell: toggle REPL (current file)")

		map("n", "<leader>rq", ht.repl.quit, "Haskell: quit REPL")
	end,
})

--completion

local ok_cmp, cmp = pcall(require, "cmp")
local ok_luasnip, luasnip = pcall(require, "luasnip")

if ok_cmp and ok_luasnip then
	require("luasnip.loaders.from_vscode").lazy_load()

	luasnip.config.setup({})

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},

		completion = {
			completeopt = "menu,menuone,noinsert",
		},

		matching = {
			disallow_fuzzy_matching = false,
			disallow_partial_matching = false,
			disallow_partial_fuzzy_matching = false,
		},

		mapping = cmp.mapping.preset.insert({
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-p>"] = cmp.mapping.select_prev_item(),

			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),

			["<C-y>"] = cmp.mapping.confirm({ select = true }),

			["<C-l>"] = cmp.mapping(function()
				if luasnip.expand_or_locally_jumpable() then
					luasnip.expand_or_jump()
				end
			end, { "i", "s" }),

			["<C-h>"] = cmp.mapping(function()
				if luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				end
			end),
		}),

		sources = {
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "path" },
		},
	})
end

--formatting

local ok_conform, conform = pcall(require, "conform")
if ok_conform then
	conform.setup({
		formatters_by_ft = {
			go = { "gofumpt", "gofmt", stop_after_first = true },
			haskell = { "fourmolu", "ormolu", stop_after_first = true },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			lua = { "stylua", stop_after_first = true },
			nix = { "nixpkgs_fmt", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			plaintex = { "latexindent", stop_after_first = true },
			tex = { "latexindent", stop_after_first = true },
		},

		format_on_save = {
			timeout_ms = 2000,
			lsp_format = "fallback",
		},
	})

	vim.o.formatexpr = 'v:lua.require("conform").formatexpr()'
end

--linting

local ok_lint, lint = pcall(require, "lint")
if ok_lint then
	lint.linters_by_ft = {
		go = { "golangcilint" },
		lua = { "selene" },
	}

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("Lint", { clear = true }),
		callback = function()
			lint.try_lint()
		end,
	})
end

--debugging

local ok_dap, dap = pcall(require, "dap")
local ok_layers, layers = pcall(require, "layers")

if ok_dap then
	dap.adapters.gdb = {
		type = "executable",
		command = "gdb",
		args = { "-i", "dap" },
	}

	dap.configurations.c = {
		{
			name = "Launch",
			type = "gdb",
			request = "launch",
			program = function()
				return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopAtBeginningOfMainSubprogram = false,
		},
	}
	dap.configurations.cpp = dap.configurations.c

	-- DAP UI
	local ok_dapui, dapui = pcall(require, "dapui")
	if ok_dapui then
		dapui.setup()

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end

		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end

		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end

		dap.listeners.before.event_exited.dapui_config = function()
			dapui.open()
		end
	end

	local ok_vtext, vtext = pcall(require, "nvim-dap-virtual-text")
	if ok_vtext then
		vtext.setup({})
	end

	if ok_layers then
		local dbg_mode = layers.mode.new()
		dbg_mode:auto_show_help()
		dbg_mode:keymaps({
			n = {
				{
					"s",
					dap.step_over,
					{ desc = "Step over" },
				},
				{
					"i",
					dap.step_into,
					{ desc = "Step into" },
				},
				{
					"S",
					dap.step_out,
					{ desc = "Step out" },
				},
				{
					"b",
					dap.toggle_breakpoint,
					{ desc = "Toggle breakpoint" },
				},
				{
					"c",
					dap.continue,
					{ desc = "Continue" },
				},
				{
					"<esc>",
					function()
						dbg_mode:deactivate()
					end,
					{ desc = "Exit" },
				},
			},
		})

		if ok_dapui then
			dbg_mode:keymaps({
				n = {
					{
						"o",
						dapui.open,
						{ desc = "Open ui" },
					},
					{
						"x",
						dapui.close,
						{ desc = "Close ui" },
					},
				},
			})
		end

		vim.keymap.set("n", "<leader>dbg", function()
			dbg_mode:activate()
		end, { desc = "Debug mode" })
	end
end

--telescope

local ok_telescope, telescope = pcall(require, "telescope")
if ok_telescope then
	local actions = require("telescope.actions")

	telescope.setup({
		defaults = {
			mappings = {
				n = {
					["<esc>"] = actions.close,
				},
			},
		},
		extensions = {
			["ui-select"] = require("telescope.themes").get_dropdown({}),
		},
	})

	pcall(telescope.load_extension, "fzf")
	pcall(telescope.load_extension, "ui-select")

	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
	vim.keymap.set("n", "<leader>rg", builtin.live_grep, { desc = "Live grep" })
	vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
end

--oil

local ok_oil, oil = pcall(require, "oil")
if ok_oil then
	oil.setup({
		default_file_explorer = true,
		columns = { "icon" },

		keymaps = {
			["gd"] = {
				desc = "Toggle detailed view",
				callback = function()
					local config = require("oil.config")

					if #config.columns == 1 then
						oil.set_columns({ "icon", "permissions", "size", "mtime" })
					else
						oil.set_columns({ "icon" })
					end
				end,
			},
		},

		view_options = {
			show_hidden = true,
		},
	})

	vim.keymap.set("n", "-", oil.open, { desc = "Open parent directory" })
end

-- gitsigns

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then
	gitsigns.setup({
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signs_staged = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signs_staged_enable = true,

		on_attach = function(bufnr)
			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end)

			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end)

			-- Actions
			map("n", "<leader>hs", gitsigns.stage_hunk)
			map("n", "<leader>hr", gitsigns.reset_hunk)

			map("v", "<leader>hs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end)

			map("v", "<leader>hr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end)

			map("n", "<leader>hS", gitsigns.stage_buffer)
			map("n", "<leader>hR", gitsigns.reset_buffer)
			map("n", "<leader>hp", gitsigns.preview_hunk)
			map("n", "<leader>hi", gitsigns.preview_hunk_inline)

			map("n", "<leader>hb", function()
				gitsigns.blame_line({ full = true })
			end)

			map("n", "<leader>hd", gitsigns.diffthis)

			map("n", "<leader>hD", function()
				gitsigns.diffthis("~")
			end)

			map("n", "<leader>hQ", function()
				gitsigns.setqflist("all")
			end)
			map("n", "<leader>hq", gitsigns.setqflist)

			map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
			map("n", "<leader>tw", gitsigns.toggle_word_diff)

			map({ "o", "x" }, "ih", gitsigns.select_hunk)
		end,
	})
end

local ok_conflict, conflict = pcall(require, "git-conflict")
if ok_conflict then
	conflict.setup()
end

local ok_gitgraph, gitgraph = pcall(require, "gitgraph")
if ok_gitgraph then
	gitgraph.setup({})

	vim.keymap.set("n", "<leader>gl", function()
		gitgraph.draw({}, { all = true, max_count = 5000 })
	end, { desc = "Draw git graph" })
end

--lualine

local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
	lualine.setup({
		options = {
			theme = "catppuccin",
			icons_enabled = vim.g.have_nerd_font,
			component_separators = { left = "│", right = "│" },
			section_separators = { left = "", right = "" },
		},
	})
end

--whichkey

local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
	wk.setup({})
end

--eyeliner

local ok_eyeliner, eyeliner = pcall(require, "eyeliner")
if ok_eyeliner then
	eyeliner.setup({
		highlight_on_key = true,
		dim = true,
	})
end

--sleuth

local function get_spaces_listchars(shift_width)
	return {
		tab = ">>",
		leadmultispace = "▏" .. (" "):rep(math.max(shift_width - 1, 0)),
	}
end

local function get_tabs_listchars(shift_width)
	return {
		leadmultispace = "__",
		tab = "▏ ",
	}
end

local function set_listchars(event)
	local is_global = vim.v.option_type == "global"
	local opts = is_global and vim.opt or vim.opt_local

	local expand_tab = opts.expandtab:get()
	local shift_width = opts.shiftwidth:get()
	local old_listchars = opts.listchars:get()

	local listchars_producer = expand_tab and get_spaces_listchars or get_tabs_listchars

	opts.listchars = vim.tbl_deep_extend("force", old_listchars, listchars_producer(shift_width))
end

vim.api.nvim_create_autocmd("OptionSet", {
	group = vim.api.nvim_create_augroup("ChangeListChars", { clear = true }),
	pattern = { "expandtab", "shiftwidth" },
	callback = set_listchars,
})
