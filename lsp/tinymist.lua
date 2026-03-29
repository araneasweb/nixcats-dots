return {
	vim.lsp.config("tinymist", {
		root_markers = { "typst.toml", ".git" },
		settings = {
			formatterMode = "typstyle",
			exportPdf = "onSave",
			outputPath = "$root/.typst/$name",
		},
	}),
}
