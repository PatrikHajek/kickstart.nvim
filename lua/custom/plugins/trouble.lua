return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  opts = {
    focus = true,
    keys = {
      ['<esc>'] = false,
      ['<cr>'] = 'jump_close',
      ['='] = 'fold_toggle',
      ['q'] = {
        action = function(view)
          if view.opts.mode ~= 'diagnostics' then
            print "Doesn't work for any other mode than diagnostics!"
          end
          local items = require('trouble').get_items()
          vim.fn.setqflist(vim.diagnostic.toqflist(items), ' ')
          vim.api.nvim_command ':q'
        end,
        desc = 'Send items to quickfix list and close the window',
      },
    },
    -- win = {},
    -- preview = {
    --   type = 'split',
    --   relative = 'win',
    --   position = 'right',
    --   size = 0.45,
    -- },
  },
}
