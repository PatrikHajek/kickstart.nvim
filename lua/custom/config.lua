--[[
  For printing (debugging) tables, use
  `vim.api.nvim_echo({ { vim.inspect(your_value) } }, false, {})`
  You can then view the whole console using `:messages`.

  INFO: To define a type for a variable you must use `---` instead of `--` for
  the comment.

  INFO: you can search for available values using Telescope's `vim.options`
  picker. You can also search registered autocommands using `autocommands` or
  highlights using `highlights`.
--]]

-- [[ Settings ]]

vim.opt.spell = true
vim.opt.spelllang = 'en_us'
vim.opt.spelloptions = 'camel'
vim.opt.spellcapcheck = ''

vim.opt.sidescrolloff = 15
vim.opt.wrap = false
vim.opt.colorcolumn = '80'
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
-- turns off 4 spaces a tab in markdown files
vim.g.markdown_recommended_style = 0
vim.opt.cursorline = false
vim.opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-blinkon0-blinkoff0-TermCursor'

vim.opt.termguicolors = true

-- [[ Keymaps ]]

-- better default experience
vim.keymap.set('x', 'p', '"_dP')
vim.keymap.set('x', '"+p', '"_d"+P')
vim.keymap.set({ 'n', 'v' }, 'd', '"_d')
vim.keymap.set({ 'n', 'v' }, 'c', '"_c')
vim.keymap.set({ 'n', 'v' }, 's', '"_s')
vim.keymap.set({ 'n', 'v' }, 'D', '"_D')
vim.keymap.set({ 'n', 'v' }, 'C', '"_C')
vim.keymap.set('n', 'S', '"_S')

vim.keymap.set('n', '<leader>vv', function()
  local line = vim.api.nvim_get_current_line()
  --- @type string|nil
  local line_trimmed = line:match '^%s*[#/-]+%s*(.+)'
  if line_trimmed then
    --- @type string
    local char = line_trimmed:sub(1, 1)
    vim.api.nvim_command('normal g_v0f' .. char)
  else
    vim.api.nvim_command 'normal g_v_'
  end
end, { desc = 'Select line without newline, comment or diff character' })
-- vim.keymap.set('n', '<leader>wb', ':w<CR>', { desc = '[W]rite [B]uffer' })
vim.keymap.set('n', '<leader>q', function()
  if vim.wo.diff then
    vim.api.nvim_command ':wincmd h | q'
    return
  end

  if #vim.api.nvim_list_wins() == 1 then
    local confirm = vim.fn.confirm 'Quit?'
    if confirm ~= 1 then
      return
    end
  end

  vim.cmd ':q'
end, { desc = '[Q]uit' })

-- [[ Buffers ]]
vim.keymap.set('n', '<leader>bb', '<C-^>', { desc = 'Switch [B]ack to Last [B]uffer' })
vim.keymap.set('n', '<leader>bd', ':bd<CR>', { desc = '[B]uffer [D]elete' })

-- [[ Vim Search ]]
vim.keymap.set('n', '<CR>', function()
  local cursorPos = vim.api.nvim_win_get_cursor(0)
  local word = vim.fn.expand '<cword>'
  if word == '' then
    return
  end
  vim.api.nvim_command('/' .. word)
  vim.api.nvim_win_set_cursor(0, cursorPos)
end, { desc = 'Search word under the cursor' })
-- NOTE: The `\z` is a lua multi-string special character - [StackOverflow](https://stackoverflow.com/a/21205005).
--       This keymap can be replaced by `*` or `#` in visual mode if you don't
--       use the multiline search.
vim.keymap.set(
  'x',
  '<CR>',
  "m0\"sy\z
  <BAR>:execute setreg('/', substitute(escape(getreg('s'), '.\\~[]*'), '\\n', '\\\\n', 'g'))\z
  <BAR>/<CR>\z
  <BAR>`0",
  { desc = 'Search selected text' }
)
vim.keymap.set('n', '/', '/\\v', { desc = 'Enable very magic for searching', noremap = true })
vim.keymap.set('n', '<leader>br', ':%s//', { desc = '[B]uffer [R]eplace' })
vim.keymap.set('v', '<leader>br', ':s//', { desc = '[B]uffer [R]eplace in selected lines' })

-- keep cursor in the middle when searching
vim.keymap.set('n', 'n', 'nzzzv', { silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { silent = true })

-- [[ Lines ]]
-- NOTE: `'<` and `'>` specify line number of the first/last line or character
-- of the selection respectively. See help for more info.
--
-- moving lines up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { silent = true })
-- copying lines up/down
vim.keymap.set('v', '<C-J>', ":co '<-1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<C-K>', ":co '><CR>gv=gv", { silent = true })

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
vim.keymap.set('n', '<leader>lbd', function()
  local diagnostics = vim.diagnostic.get(0)
  vim.fn.setqflist(vim.diagnostic.toqflist(diagnostics), ' ')
  vim.api.nvim_command ':Trouble quickfix'
end, { desc = "Populate quickfix list with current buffer's diagnostics and open it" })

-- quickfix keymaps
vim.keymap.set('n', '<leader>sq', ':Telescope quickfixhistory<CR>', { desc = '[S]earch [Q]uickfix history' })
vim.keymap.set('n', '<leader>lq', ':Trouble quickfix<CR>', { desc = 'Show quickfix list' })
vim.keymap.set('n', '<C-n>', ':cnext<CR>', { desc = 'Go to next quickfix item' })
vim.keymap.set('n', '<C-p>', ':cprev<CR>', { desc = 'Go to prev quickfix item' })
vim.keymap.set('n', '<leader>vg', ':vimgrep //gj ', { desc = '[V]im[G]rep using search register' })
vim.keymap.set('n', '<leader>vr', ':cdo s//', { desc = '[V]im [R]eplace' })

-- [[ Todo Highlights ]]
vim.keymap.set('n', '<leader>tt', ':TodoTelescope<CR>', { desc = 'Search [T]odos using [T]elescope' })
vim.keymap.set('n', '<leader>lt', ':Trouble todo<CR>', { desc = 'Search [T]odos using [T]elescope' })

-- [[ Git ]]
vim.keymap.set('n', '<leader>gb', ':Telescope git_branches<CR>', { desc = '[G]it [B]ranches' })
vim.keymap.set('n', '<leader>gc', ':Telescope git_commits<CR>', { desc = '[G]it [C]ommits' })
vim.keymap.set('n', '<leader>bc', ':Telescope git_bcommits<CR>', { desc = 'Show [B]uffer [C]ommits' })

-- [[ Diff ]]
vim.keymap.set('n', 'dS', function()
  if vim.wo.diff then
    vim.api.nvim_command ':wa'
    print 'All buffers were saved'
  else
    print 'Not in diff'
  end
end, { desc = '[d]iff [S]ave all buffers' })

-- [[ Search ]]
vim.keymap.set('n', '<leader>st', ':Telescope treesitter<CR>', { desc = '[S]earch [T]reesitter' })
vim.keymap.set('n', '<leader>saf', function()
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
end, { desc = '[S]earch [A]ll [F]iles' })
vim.keymap.set('n', '<leader>sag', function()
  require('telescope.builtin').live_grep {
    additional_args = { '--no-ignore' },
    glob_pattern = { '!node_modules' },
  }
end, { desc = '[S]earch [A]ll files using [G]rep' })
vim.keymap.set('n', '<leader>sp', function()
  require('telescope.builtin').find_files { cwd = vim.fn.expand '$HOME/notes/' }
end, { desc = '[S]earch [P]KM' })
vim.keymap.set('n', '<leader>so', function()
  require('telescope.builtin').find_files { cwd = vim.fn.expand '$HOME/notes-tomake/' }
end, { desc = '[S]earch [O]rganization Notes (Tomake)' })

-- [[ LSP ]]
vim.keymap.set('n', '<leader>rl', ':LspRestart<CR>', { desc = '[R]estart [L]SP' })

local function get_servers()
  local vue_language_server_path = require('mason-registry').get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
  return {
    -- formatters
    prettierd = {},
    black = {},
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
    volar = {
      settings = {
        css = { lint = { unknownAtRules = 'ignore' } },
      },
    },
    cssls = {
      settings = {
        css = { lint = { unknownAtRules = 'ignore' } },
      },
    },
    tailwindcss = {
      filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'css', 'html' },
    },
    prismals = {},
    jsonls = {},
    html = { filetypes = { 'html', 'twig', 'hbs' } },
    bashls = {
      filetypes = { 'sh' },
    },
    markdown_oxide = {},
    markdownlint = {},
    clangd = {},
    -- java_language_server = {},
    jdtls = {},
    pyright = {},
    rust_analyzer = {},
  }
end

local function go_to_definition()
  vim.lsp.buf.definition {
    on_list = function(opts)
      ---@alias item {filename: string, text: string}[]

      ---@type item
      local items = opts.items

      ---@type item
      local filtered = {}
      for k in pairs(items) do
        local item = items[k]
        if item.filename:find '%.nuxt/components%.d%.ts' or not item.filename:find '%.nuxt' then
          filtered[#filtered + 1] = items[k]
        end
      end

      if #filtered == 0 then
        vim.fn.setloclist(0, items)
        if #items == 1 then
          vim.api.nvim_command ':lfirst'
        elseif #items > 1 then
          require('telescope.builtin').loclist()
        else
          vim.notify 'No definitions found'
        end
        return
      end

      vim.fn.setloclist(0, filtered)
      if #filtered > 1 then
        require('telescope.builtin').loclist()
        return
      end

      local item = filtered[1]
      if item.filename:find '%.nuxt/components%.d%.ts' then
        local filename = item.filename:match '(.+)components%.d%.ts'
        local path = item.text:match 'import%("(.+)"%)'
        local ext = path:match '.+%.(%w+)$'
        local extension = ext == 'vue' and '' or '.d.ts'

        if not path or not filename then
          vim.notify "File path couldn't be extracted"
        else
          vim.api.nvim_command(':e ' .. filename .. path .. extension)
        end
      else
        vim.api.nvim_command ':lfirst'
      end
    end,
  }
end

-- references
local function goto_next_reference()
  vim.lsp.buf.references(nil, {
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
  vim.lsp.buf.references(nil, {
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
vim.keymap.set('n', ']r', goto_next_reference, { desc = 'Go to next reference' })
vim.keymap.set('n', '[r', goto_prev_reference, { desc = 'Go to previous reference' })
vim.keymap.set('n', '<leader>lr', ':Trouble lsp_references<CR>', { desc = '[L]ist [R]eferences in Trouble window' })

-- [[ Imported commands ]]
require 'custom.commands.unsaved-buffers'
require 'custom.commands.buffer-info'

return {
  get_servers = get_servers,
  go_to_definition = go_to_definition,
}
