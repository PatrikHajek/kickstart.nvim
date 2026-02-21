return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  opts = {
    focus = true,
    keys = {
      ['<esc>'] = false,
      ['<cr>'] = 'jump_close',
      ['='] = 'fold_toggle',
      ['f'] = {
        action = function()
          vim.cmd 'q'
          vim.cmd 'cfirst'
        end,
        desc = 'Close and jump to the first item',
      },
      ['c'] = {
        action = function(view)
          if view.opts.mode == 'diagnostics' then
            local items = require('trouble').get_items()
            vim.fn.setqflist(vim.diagnostic.toqflist(items), ' ')
            vim.api.nvim_command ':q'
          elseif view.opts.mode == 'lsp_references' then
            vim.api.nvim_command ':q'
            vim.lsp.buf.references(nil, {
              on_list = function(options)
                --- This is done per documentation: `:help vim.lsp.listOpts`.
                --- @diagnostic disable-next-line: param-type-mismatch
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
      quickfix = {
        -- More info in the [source](https://github.com/folke/trouble.nvim/blob/bd67efe408d4816e25e8491cc5ad4088e708a69a/lua/trouble/sources/lsp.lua#L112).
        title = '{hl:Title} QuickFix {hl} {count}',
      },
      diagnostics = {
        filter = {
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
          },
        },
      },
      -- Can be used to include the item the cursor is on in lsp_references window.
      -- lsp_base = {
      --   params = {
      --     include_current = true,
      --   },
      -- },
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
