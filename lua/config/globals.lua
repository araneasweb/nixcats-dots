vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.loaded_sexp_mappings_for_regular_people = 1

local function from_nix(path, default)
	if type(nixCats) ~= "function" then
		return default
	end

	local ok, value = pcall(nixCats, path)
	if ok and value ~= nil then
		return value
	end

	return default
end

vim.g.have_nerd_font = from_nix("have_nerd_font", true)
