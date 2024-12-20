-- INFO: you can search for available values using Telescope's `vim.options`
-- picker. You can also search registered autocommands using `autocommands`.

-- [[ Settings ]]

vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.opt.spelloptions = 'camel'

vim.opt.wrap = false
vim.opt.colorcolumn = '80'
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
-- turns off 4 spaces a tab in markdown files
vim.g.markdown_recommended_style = 0

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
vim.keymap.set('n', '<leader>wb', ':w<CR>', { desc = '[W]rite [B]uffer' })
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

-- [[ Vim Search ]]
vim.keymap.set('n', '<CR>', function()
  local cursorPos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_command('/' .. vim.fn.expand '<cword>')
  vim.api.nvim_win_set_cursor(0, cursorPos)
end, { desc = 'Search word under the cursor' })
vim.keymap.set('x', '<CR>', '"sy<BAR>/<C-r>s<CR>', { desc = 'Search selected text' })
vim.keymap.set('n', '/', '/\\v', { desc = 'Enable very magic for searching', noremap = true })
vim.keymap.set('n', '<leader>vr', ':%s//', { desc = '[V]im [R]eplace' })
vim.keymap.set('v', '<leader>vr', ':s//', { desc = '[V]im [R]eplace in selected lines' })

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
vim.keymap.set('n', '<leader>k', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- quickfix keymaps
vim.keymap.set('n', '<leader>sq', ':Telescope quickfix<CR>', { desc = '[S]earch [Q]uickfix list' })
vim.keymap.set('n', '<leader>lq', ':cwindow<CR>', { desc = 'Show quickfix list' })
vim.keymap.set('n', '<C-n>', ':cnext<CR>', { desc = 'Go to next quickfix item' })
vim.keymap.set('n', '<C-p>', ':cprev<CR>', { desc = 'Go to prev quickfix item' })
vim.keymap.set('n', '<leader>vg', ':vimgrep //g ', { desc = '[V]im[G]rep using search register' })

-- [[ Git ]]
vim.keymap.set('n', '<leader>gb', ':Telescope git_branches<CR>', { desc = '[G]it [B]ranches' })
vim.keymap.set('n', '<leader>gc', ':Telescope git_commits<CR>', { desc = '[G]it [C]ommits' })

-- [[ Search ]]
vim.keymap.set('n', '<leader>st', ':Telescope treesitter<CR>', { desc = '[S]earch [T]reesitter' })
vim.keymap.set('n', '<leader>sa', function()
  require('telescope.builtin').find_files {
    find_command = {
      'rg',
      '--files',
      '--follow',
      '--hidden',
      '--no-ignore',
      '--glob=!.git',
      '--glob=!node_modules',
    },
  }
end, { desc = '[S]earch [A]ll files' })

-- [[ LSP ]]
vim.keymap.set('n', '<leader>rl', ':LspRestart<CR>', { desc = '[R]estart [L]SP' })

local function get_servers()
  local vue_language_server_path = require('mason-registry').get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
  return {
    -- formatters
    prettierd = {},
    -- linters
    eslint_d = {},
    -- servers
    ts_ls = {
      init_options = {
        plugins = {
          {
            name = '@vue/typescript-plugin',
            location = vue_language_server_path,
            languages = { 'vue' },
          },
        },
      },
      filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    },
    volar = {},
    cssls = {},
    tailwindcss = {},
    prismals = {},
    jsonls = {},
    html = { filetypes = { 'html', 'twig', 'hbs' } },
    bashls = {
      filetypes = { 'sh' },
    },
    marksman = {},
    markdown_oxide = {},
    markdownlint = {},
    clangd = {},
    java_language_server = {},
    jdtls = {},
    pyright = {},
  }
end

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

return {
  get_servers = get_servers,
}
