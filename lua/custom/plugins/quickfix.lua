return {
  {
    'kiyoon/repeatable-move.nvim',
    init = function()
      vim.keymap.set('n', '?', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

      local diagnostic_next, diagnostic_prev = require('repeatable_move').make_repeatable_move_pair(function()
        vim.diagnostic.jump { count = 1, float = true }
      end, function()
        vim.diagnostic.jump { count = -1, float = true }
      end)
      vim.keymap.set('n', ']d', diagnostic_next, { desc = 'Next diagnostic' })
      vim.keymap.set('n', '[d', diagnostic_prev, { desc = 'Previous diagnostic' })

      vim.keymap.set('n', '<leader>ld', function()
        local diagnostics = vim.diagnostic.get()
        vim.fn.setqflist(vim.diagnostic.toqflist(diagnostics), ' ')
        vim.cmd 'Trouble quickfix'
      end, { desc = '[L]ist [D]iagnostics' })
    end,
  },
}
