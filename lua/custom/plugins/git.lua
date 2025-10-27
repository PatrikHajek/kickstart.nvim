return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>G', ':tab Git<CR> | 5G_', { desc = 'Open [G]it' })

      vim.keymap.set('n', 'gfug_', '_')
      vim.api.nvim_create_autocmd({ 'BufEnter' }, {
        pattern = { 'fugitive://*' },
        callback = function(ev)
          vim.keymap.set('n', '_', function()
            local line = vim.api.nvim_get_current_line()
            local should_skip = line:find '^[AMRD+-] '
            if should_skip then
              vim.api.nvim_command ':normal 0w'
            else
              vim.api.nvim_command ':normal gfug_'
            end
          end, { buffer = ev.buf })
        end,
      })
    end,
  },
  'tpope/vim-rhubarb',
}
