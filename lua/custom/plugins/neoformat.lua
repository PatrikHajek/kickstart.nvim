return {
	'sbdchd/neoformat',
	config = function()
		vim.keymap.set('n', '<leader>fm', ':Neoformat<cr>', { noremap = true, silent = true })
	end
}
