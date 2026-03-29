local util = require("config.util")
local builtin = require("telescope.builtin")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

vim.lsp.config("*", {
	capabilities = capabilities,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = util.augroup("lsp_attach"),
	callback = function(event)
		local bufnr = event.buf

		local function map(lhs, rhs, desc)
			util.bufmap(bufnr, "n", lhs, rhs, "LSP: " .. desc)
		end

		map("gd", builtin.lsp_definitions, "Goto definition")
		map("gr", builtin.lsp_references, "Goto references")
		map("gI", builtin.lsp_implementations, "Goto implementation")
		map("<leader>D", builtin.lsp_type_definitions, "Goto type definition")
		map("<leader>ds", builtin.lsp_document_symbols, "Document symbols")
		map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
		map("<leader>rn", vim.lsp.buf.rename, "Rename")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("<leader>oc", builtin.lsp_outgoing_calls, "Outgoing calls")
		map("<leader>ic", builtin.lsp_incoming_calls, "Incoming calls")
		map("K", vim.lsp.buf.hover, "Hover documentation")
		map("gD", vim.lsp.buf.declaration, "Goto declaration")
		map("[d", vim.diagnostic.goto_prev, "Goto previous diagnostic")
		map("]d", vim.diagnostic.goto_next, "Goto next diagnostic")

		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end

		if client.server_capabilities.documentHighlightProvider then
			local group = vim.api.nvim_create_augroup("user_lsp_document_highlight", { clear = false })

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = bufnr,
				group = group,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = bufnr,
				group = group,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = util.augroup("lsp_detach_cleanup_" .. bufnr),
				buffer = bufnr,
				callback = function(detach_event)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = group, buffer = detach_event.buf })
				end,
			})
		end

		if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
			end, "Toggle inlay hints")

			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end,
})

vim.lsp.enable({
	"clangd",
	"glsl_analyzer",
	"gopls",
	"hls",
	"lua_ls",
	"nil_ls",
	"racket_langserver",
	"rust_analyzer",
	"texlab",
	"ts_ls",
	"markdown",
	"tinymist",
})
