return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>G', ':tab Git<CR>', { desc = 'Open [G]it' })
    end,
  },
  'tpope/vim-rhubarb',
}
