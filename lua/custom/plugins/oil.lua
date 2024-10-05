return {
  'stevearc/oil.nvim',
  opts = {
    columns = {
      'size',
      'icon',
    },
  },
  config = function(_, opts)
    local oil = require 'oil'
    oil.setup(opts)
    vim.keymap.set('n', '<leader>e', oil.toggle_float, { desc = 'Open [E]xplorer' })
  end,
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
