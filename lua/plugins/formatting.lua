local map = require("config.util").map
local conform = require("conform")

conform.setup({
	notify_on_error = false,
	formatters_by_ft = {
		go = { "gofumpt", "gofmt", stop_after_first = true },
		haskell = { "fourmolu", "ormolu", stop_after_first = true },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		lua = { "stylua", stop_after_first = true },
		nix = { "nixpkgs_fmt", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		plaintex = { "latexindent", stop_after_first = true },
		racket = { "racofixw", stop_after_first = true },
		tex = { "latexindent", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
	},
	formatters = {
		racofixw = {
			command = "raco",
			args = { "fixw" },
			stdin = true,
		},
		racofmt = {
			command = "raco",
			args = { "fmt", "--width", "80", "--max-blank-lines", "1" },
			stdin = true,
		},
	},
	format_on_save = function(bufnr)
		local disable_lsp_fallback = {
			c = true,
			cpp = true,
		}

		return {
			timeout_ms = 10000,
			lsp_format = disable_lsp_fallback[vim.bo[bufnr].filetype] and "never" or "fallback",
		}
	end,
})

vim.o.formatexpr = "v:lua.require('conform').formatexpr()"

map({ "n", "v" }, "<leader>f", function()
	conform.format({ async = true, lsp_format = "fallback" })
end, "Format buffer or selection")
