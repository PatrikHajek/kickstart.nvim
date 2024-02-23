return {
	'sbdchd/neoformat',
	config = function()
		vim.keymap.set('n', '<leader>fm', ':Neoformat<cr>', { desc = "[F]or[m]at using Neoformat", noremap = true, silent = true })
		vim.keymap.set('n', '<leader>fw', ':Neoformat <BAR> :w<cr>', {desc = "[F]ormat and [W]rite", noremap = true, silent = true })
	end
}
