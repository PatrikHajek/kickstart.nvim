--- Delete items from Trouble quickfix window.
--- @param ids string[] List of item ids to be deleted.
local function delete(ids)
  local trouble = require 'trouble'

  --- @param item trouble.Item
  local items = vim.tbl_filter(function(item)
    return not vim.list_contains(ids, item.id)
  end, trouble.get_items())

  --- @param item trouble.Item
  --- @type vim.quickfix.entry[]
  local qf_entries = vim.tbl_map(function(item)
    return item.item
  end, items)
  vim.fn.setqflist(qf_entries, 'r')
  trouble.refresh()
end

return {
  {
    'folke/trouble.nvim',
    dependencies = {
      'kiyoon/repeatable-move.nvim',
    },
    cmd = 'Trouble',
    --- @type trouble.Config
    opts = {
      focus = true,
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
      preview = { scratch = false },
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
        ['d'] = {
          --- @param view trouble.View
          action = function(view)
            if view.opts.mode ~= 'quickfix' then
              print 'Deletions only work in quickfix windows!'
              return
            end

            local selection = view:selection()
            --- @type string[]
            local ids = {}
            for _, node in ipairs(selection) do
              --- @param item trouble.Item
              local item_ids = vim.tbl_map(function(item)
                return item.id
              end, node:flatten())
              vim.list_extend(ids, item_ids)
            end

            delete(ids)
          end,
          desc = 'Delete selected nodes',
        },
        ['dd'] = {
          --- @param view trouble.View
          action = function(view)
            if view.opts.mode ~= 'quickfix' then
              print 'Deletions only work in quickfix windows!'
              return
            end

            local at = view:at()
            if at.node ~= nil then
              --- @param item trouble.Item
              local item_ids = vim.tbl_map(function(item)
                return item.id
              end, at.node:flatten())
              delete(item_ids)
            else
              print "Couldn't get current node"
            end
          end,
          desc = 'Delete the node under the cursor',
        },
      },
    },
    init = function()
      -- [[ Quickfix ]]
      vim.keymap.set('n', '<leader>cf', ':cfirst<CR>', { desc = 'Go to the first item in quickfix list' })
      vim.keymap.set('n', '<leader>cl', ':clast<CR>', { desc = 'Go to the last item in quickfix list' })
      vim.keymap.set('n', '<C-l>', ':cnext<CR>', { desc = 'Go to next quickfix item' })
      vim.keymap.set('n', '<C-h>', ':cprev<CR>', { desc = 'Go to prev quickfix item' })

      vim.keymap.set('n', '<leader>co', function()
        local trouble = require 'trouble'
        if vim.bo.filetype == 'trouble' then
          trouble.close()
        else
          trouble.open 'quickfix'
        end
      end, { desc = 'Open quickfix list' })

      vim.keymap.set('n', '<leader>cr', function()
        vim.lsp.buf.references(nil, {
          on_list = function(o)
            --- This is done per documentation: `:help vim.lsp.listOpts`.
            --- @diagnostic disable-next-line: param-type-mismatch
            vim.fn.setqflist({}, 'r', o)
            vim.cmd 'Trouble quickfix'
          end,
        })
      end, { desc = 'Fill quickfix list with references' })
      vim.keymap.set('n', '<leader>chu', function()
        require('gitsigns').setqflist 'all'
      end, { desc = 'Fill quickfix list with unstaged hunks' })

      vim.keymap.set('n', '<leader>vg', ':vimgrep //gj ', { desc = '[V]im[G]rep using search register' })
      vim.keymap.set('n', '<leader>vr', ':cdo s//', { desc = '[V]im [R]eplace' })

      vim.cmd 'packadd cfilter'
      vim.api.nvim_create_user_command('Crefine', function(args)
        local command = args.bang and 'Cfilter!' or 'Cfilter'
        local arg = #args.fargs == 1 and args.fargs[1] or vim.fn.getreg '/'
        vim.cmd(command .. ' ' .. arg)
        require('trouble').refresh()
      end, { bang = true, nargs = '?', desc = 'Calls Cfilter and refreshes trouble window' })

      vim.keymap.set('n', '<leader>sq', ':Telescope quickfixhistory<CR>', { desc = '[S]earch [Q]uickfix history' })

      -- [[ Diagnostics ]]
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
