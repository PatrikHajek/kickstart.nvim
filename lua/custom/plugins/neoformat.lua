local neoformat_filetypes = {
	'javscript',
	'typescript',
	'vue',
	'json',
	'html',
	'css',
	'svg',
}
local function format()
	if vim.tbl_contains(neoformat_filetypes, vim.bo.filetype) then
		vim.cmd('Neoformat')
		return
	end

	vim.lsp.buf.format()
end

return {
	'sbdchd/neoformat',
	config = function()
		vim.keymap.set('n', '<leader>fm', format,
			{ desc = "[F]or[m]at using Neoformat", noremap = true, silent = true })
		vim.keymap.set('n', '<leader>fw', function()
				format()
				vim.cmd(':w<cr>')
			end,
			{ desc = "[F]ormat and [W]rite", noremap = true, silent = true })
	end
}
