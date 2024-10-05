-- [[ Settings ]]

vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.colorcolumn = '80'
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

-- [[ Keymaps ]]

-- better default experience
vim.keymap.set('x', 'p', '"_dP')
vim.keymap.set({ 'n', 'v' }, 'd', '"_d')
vim.keymap.set({ 'n', 'v' }, 'c', '"_c')
vim.keymap.set({ 'n', 'v' }, 's', '"_s')
vim.keymap.set({ 'n', 'v' }, 'D', '"_D')
vim.keymap.set({ 'n', 'v' }, 'C', '"_C')
vim.keymap.set('n', 'S', '"_S')

vim.keymap.set('n', '<leader>vv', 'g_v_', { desc = 'Select line without newline character' })
vim.keymap.set('n', '<leader>wf', ':w<CR>', { desc = '[W]rite Buffer to the Current [F]ile' })
vim.keymap.set('n', '<leader>bb', '<C-^>', { desc = 'Switch [B]ack to Last [B]uffer' })
vim.keymap.set('n', '<leader>q', function()
  if #vim.api.nvim_list_wins() == 1 then
    local confirm = vim.fn.confirm 'Quit?'
    if confirm ~= 1 then
      return
    end
  end

  vim.cmd ':q'
end, { desc = '[Q]uit' })

-- keep cursor in the middle when searching
vim.keymap.set('n', 'n', 'nzzzv', { silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { silent = true })

-- moving lines up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { silent = true })

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- quickfix keymaps
vim.keymap.set('n', ']q', ':cnext<CR>', { desc = 'Go to next quickfix item' })
vim.keymap.set('n', '[q', ':cprev<CR>', { desc = 'Go to prev quickfix item' })

-- [[ LSP ]]
vim.keymap.set('n', '<leader>rl', ':LspRestart<CR>', { desc = '[R]estart [L]SP' })

-- references
local function goto_next_reference()
  vim.lsp.buf.references({}, {
    on_list = function(r)
      local filename = r.context.params.textDocument.uri
      local cursor = vim.api.nvim_win_get_cursor(0)
      local items = r.items
      local next_item = nil
      local fallback_item = nil
      for _, item in pairs(items) do
        if item.filename ~= string.sub(filename, 8) then
          goto continue
        end

        if fallback_item == nil then
          fallback_item = item
        end

        -- lsp for some reason returns columns 1 bigger
        item.col = item.col - 1

        if item.lnum == cursor[1] and item.col > cursor[2] then
          next_item = item
          break
        elseif item.lnum > cursor[1] and item.lnum then
          next_item = item
          break
        end

        ::continue::
      end

      if next_item == nil then
        next_item = fallback_item
      end

      vim.api.nvim_win_set_cursor(0, { next_item.lnum, next_item.col })
    end,
  })
end
local function goto_prev_reference()
  vim.lsp.buf.references({}, {
    on_list = function(r)
      local filename = r.context.params.textDocument.uri
      local cursor = vim.api.nvim_win_get_cursor(0)
      local items = vim.fn.reverse(r.items)
      local prev_item = nil
      local fallback_item = nil
      for _, item in pairs(items) do
        if item.filename ~= string.sub(filename, 8) then
          goto continue
        end

        if fallback_item == nil then
          fallback_item = item
        end

        -- lsp for some reason returns columns 1 bigger
        item.col = item.col - 1

        if item.lnum == cursor[1] and item.col < cursor[2] then
          prev_item = item
          break
        elseif item.lnum < cursor[1] then
          prev_item = item
          break
        end

        ::continue::
      end

      if prev_item == nil then
        prev_item = fallback_item
      end

      vim.api.nvim_win_set_cursor(0, { prev_item.lnum, prev_item.col })
    end,
  })
end
vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, { desc = '[L]ist [R]eferences' })
vim.keymap.set('n', ']r', goto_next_reference, { desc = 'Go to next reference' })
vim.keymap.set('n', '[r', goto_prev_reference, { desc = 'Go to previous reference' })

-- [[ Imported commands ]]
require 'custom.commands.unsaved-buffers'
require 'custom.commands.buffer-info'
