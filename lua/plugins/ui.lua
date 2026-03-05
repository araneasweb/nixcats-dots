require("fidget").setup({})
require("nvim-surround").setup({})

require("which-key").setup({})
require("which-key").add({
	{ "<leader>d", group = "[D]ebug/[D]iagnostics" },
	{ "<leader>f", group = "[F]ind/[F]ormat" },
	{ "<leader>g", group = "[G]it" },
	{ "<leader>h", group = "Git [H]unk" },
	{ "<leader>r", group = "[R]ename/REPL" },
	{ "<leader>t", group = "[T]oggle" },
	{ "<leader>x", group = "E[x]ecute" },
	{ "<leader>l", group = "[L]anguage" },
	{ "<leader>lh", group = "[H]askell" },
	{ "<leader>ls", group = "[S]exp" },
	{ "<leader>lc", group = "[C]onjure" },
})

require("eyeliner").setup({
	highlight_on_key = true,
	dim = true,
})

require("lualine").setup({
	options = {
		theme = "catppuccin",
		icons_enabled = vim.g.have_nerd_font,
		component_separators = { left = "│", right = "│" },
		section_separators = { left = "", right = "" },
	},
})
