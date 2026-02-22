--- @param item trouble.Item
--- @return vim.quickfix.entry
local function to_qf_entry(item)
  return item.item
end

--- Delete items from Trouble quickfix window.
--- @param ids string[] List of item ids to be deleted.
local function delete(ids)
  local trouble = require 'trouble'

  --- @param item trouble.Item
  local items = vim.tbl_filter(function(item)
    return not vim.list_contains(ids, item.id)
  end, trouble.get_items())

  --- @type vim.quickfix.entry[]
  local qf_entries = vim.tbl_map(to_qf_entry, items)
  vim.fn.setqflist(qf_entries, 'r')
  trouble.refresh()
end

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
    -- win = {},
    -- preview = {
    --   type = 'split',
    --   relative = 'win',
    --   position = 'right',
    --   size = 0.45,
    -- },
  },
}
