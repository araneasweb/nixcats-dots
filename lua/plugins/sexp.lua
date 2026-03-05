local util = require("config.util")

vim.g.sexp_filetypes = ""
vim.g.sexp_no_word_maps = 1
vim.g.sexp_enable_insert_mode_mappings = 0

vim.api.nvim_create_autocmd("FileType", {
	group = util.augroup("lang_sexp_keymaps"),
	pattern = { "clojure", "scheme", "lisp", "fennel", "racket", "timl" },
	callback = function(event)
		local bufnr = event.buf
		local function ls(key, plug, desc)
			util.bufmap(bufnr, "n", "<leader>ls" .. key, plug, desc, { remap = true })
		end

		ls(">", "<Plug>(sexp_capture_next_element)", "Sexp: slurp right")
		ls("<", "<Plug>(sexp_capture_prev_element)", "Sexp: slurp left")
		ls(")", "<Plug>(sexp_emit_tail_element)", "Sexp: barf right")
		ls("(", "<Plug>(sexp_emit_head_element)", "Sexp: barf left")

		ls("s", "<Plug>(sexp_splice_list)", "Sexp: splice list")
		ls("r", "<Plug>(sexp_raise_list)", "Sexp: raise list")
		ls("R", "<Plug>(sexp_raise_element)", "Sexp: raise element")
		ls("f", "<Plug>(sexp_swap_list_forward)", "Sexp: swap list forward")
		ls("F", "<Plug>(sexp_swap_list_backward)", "Sexp: swap list backward")
		ls("e", "<Plug>(sexp_swap_element_forward)", "Sexp: swap element forward")
		ls("E", "<Plug>(sexp_swap_element_backward)", "Sexp: swap element backward")

		ls("i", "<Plug>(sexp_insert_at_list_head)", "Sexp: insert at list head")
		ls("I", "<Plug>(sexp_insert_at_list_tail)", "Sexp: insert at list tail")
	end,
})
