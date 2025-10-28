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
            if line:find '^[AMRD+-] ' then
              vim.api.nvim_command ':normal 0w'
            elseif line:find '^[AMRD+-]' then
              vim.api.nvim_command ':normal 0l'
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
