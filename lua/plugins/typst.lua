local util = require("config.util")

require("typst-preview").setup({
	dependencies_bin = {
		tinymist = "tinymist",
		websocat = "websocat",
	},
	follow_cursor = false,
	open_cmd = "qutebrowser --target window --desktop-file-name typst-preview %s",
})

vim.api.nvim_create_autocmd("FileType", {
	group = util.augroup("typst_tools"),
	pattern = { "typst" },
	callback = function(event)
		local bufnr = event.buf

		local function pdf_path()
			local file = vim.api.nvim_buf_get_name(bufnr)
			local root = vim.fs.root(file, { "typst.toml", ".git" }) or vim.fs.dirname(file)
			local name = vim.fn.fnamemodify(file, ":t:r")
			return root .. "/.typst/" .. name .. ".pdf"
		end

		util.bufmap(bufnr, "n", "<leader>ltp", "<cmd>TypstPreviewToggle<cr>", "Typst: toggle preview")
		util.bufmap(bufnr, "n", "<leader>lts", "<cmd>TypstPreviewSyncCursor<cr>", "Typst: sync preview")
		util.bufmap(bufnr, "n", "<leader>ltf", "<cmd>TypstPreviewFollowCursorToggle<cr>", "Typst: toggle follow cursor")
		util.bufmap(bufnr, "n", "<leader>lte", "<cmd>LspTinymistExportPdf<cr>", "Typst: export PDF")

		util.bufmap(bufnr, "n", "<leader>ltv", function()
			vim.fn.jobstart({ "sioyek", pdf_path() }, { detach = true })
		end, "Typst: open PDF in Sioyek")
	end,
})
