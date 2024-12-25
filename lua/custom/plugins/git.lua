return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>G', ':tab Git<CR> | 5G_', { desc = 'Open [G]it' })
    end,
  },
  'tpope/vim-rhubarb',
}
