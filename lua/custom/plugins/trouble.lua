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
          if view.opts.mode == 'diagnostics' then
            local items = require('trouble').get_items()
            vim.fn.setqflist(vim.diagnostic.toqflist(items), ' ')
            vim.api.nvim_command ':q'
          elseif view.opts.mode == 'lsp_references' then
            vim.api.nvim_command ':q'
            -- NOTE: from `:help vim.lsp.listOpts`
            vim.lsp.buf.references(nil, {
              on_list = function(options)
                vim.fn.setqflist({}, 'r', options)
              end,
            })
          else
            print "Doesn't work for any other modes than diagnostics and lsp_references!"
          end
        end,
        desc = 'Send items to quickfix list and close the window',
      },
    },
    modes = {
      diagnostics = {
        filter = {
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
          },
        },
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
