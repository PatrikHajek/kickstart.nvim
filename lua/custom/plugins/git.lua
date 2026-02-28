--- Get the commit count difference between target and HEAD.
--- @param target string
--- @return integer
local function get_commit_count(target)
  local cmd = ('git rev-list --count %s..HEAD'):format(target)
  local count = vim.fn.system(cmd):gsub('%s+', '')
  return tonumber(count) or 0
end

--- Get the commit hash.
--- @param commit_index integer Must be greater than or equal to 0.
--- @return string
local function get_commit_diff_hash(commit_index)
  assert(commit_index >= 0, 'There must be at least 1 commit left to open diff.')
  return ('HEAD~%i..HEAD~%i'):format(commit_index + 1, commit_index)
end

--- Get the commit hash.
--- @param commit_index integer
--- @return string
local function get_commit_hash(commit_index)
  return ('HEAD~%i'):format(commit_index)
end

local commit_count --- @type integer
local commit_index --- @type integer

--- Initialize the state.
--- @param target string
local function init(target)
  commit_count = get_commit_count(target)
  commit_index = commit_count - 1
end

--- Open diff against the adjacent commits.
local function open_diff()
  -- TODO: Could possibly use `DiffviewRefresh` for a smoother experience.
  vim.cmd 'DiffviewClose'
  vim.cmd('DiffviewOpen ' .. get_commit_diff_hash(commit_index))
  print(('Commit HEAD~%i / %i'):format(commit_index, commit_count))
end

local function show()
  local hash = get_commit_hash(commit_index)
  -- `-s` suppresses diff.
  vim.cmd('G show -s ' .. hash)
end

local BRANCH_DEFAULT = 'origin/HEAD'

--- @type table<string, fun(args: string[])>
local commands = {
  -- TODO: Add autocomplete for branches here.
  init = function(args)
    -- TODO: Validate?
    local target = args[1] or BRANCH_DEFAULT
    init(target)
  end,

  next = function()
    if commit_index > 0 then
      commit_index = commit_index - 1
      open_diff()
    else
      print 'Reached the last commit'
    end
  end,

  prev = function()
    commit_index = commit_index + 1
    open_diff()
  end,

  first = function()
    commit_index = commit_count - 1
    open_diff()
  end,

  last = function()
    commit_index = 0
    open_diff()
  end,

  diff = function()
    open_diff()
  end,

  show = show,
}

init(BRANCH_DEFAULT)

-- TODO: When navigating, show the commit info first and then, upon closing the buffer, jump to the
-- diff.
-- TODO: Add autocomplete.
-- FIX: Calling `:Commit show` closes diff.
-- TODO: Add good API to force the user to `git pull` and start reviewing from the first commit.
-- TODO: Support count in next and prev commands to skip commits.
-- TODO: Option to specify target.
-- TODO: Support going beyond the first commit?
-- TODO: Create a telescope git_commits action that uses this logic to diff the chosen commit.
vim.api.nvim_create_user_command('Commit', function(args)
  local command = args.fargs[1]
  if commands[command] ~= nil then
    local command_args = vim.list_slice(args.fargs, 2)
    commands[command](command_args)
  else
    print 'Not a command'
  end
end, { desc = 'See introduced changes commit by commit', nargs = '*' })

return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>G', ':tab Git<CR> | 5G_', { desc = 'Open [G]it' })

      vim.keymap.set('n', 'gfug_', '_')
      vim.api.nvim_create_autocmd({ 'BufEnter' }, {
        pattern = { 'fugitive://*' },
        callback = function(ev)
          vim.keymap.set({ 'n', 'x' }, '_', function()
            local line = vim.api.nvim_get_current_line()
            --- @type string | nil
            local line_trimmed = line:match '^[AMRD+-] *(.+)'
            if line_trimmed then
              --- @type string
              local char = line_trimmed:sub(1, 1)
              vim.api.nvim_command(':normal 0f' .. char)
            else
              vim.api.nvim_command ':normal gfug_'
            end
          end, { buffer = ev.buf })
        end,
      })

      vim.api.nvim_create_autocmd('WinNew', {
        pattern = 'fugitive://*',
        callback = function()
          vim.schedule(function()
            if vim.wo.diff then
              local TAB_BAR_HEIGHT = 1
              local STATUSLINE_HEIGHT = 1
              local BUFFER_PATH_HEIGHT = 1
              local FUGITIVE_HEIGHT = 1
              local height = vim.o.lines - TAB_BAR_HEIGHT - STATUSLINE_HEIGHT - vim.o.cmdheight - BUFFER_PATH_HEIGHT * 2 - FUGITIVE_HEIGHT
              -- Go to the top window - fugitive buffer.
              vim.cmd 'wincmd t'
              vim.api.nvim_win_set_height(0, FUGITIVE_HEIGHT)
              vim.cmd 'wincmd j'
              vim.api.nvim_win_set_height(0, math.floor(height / 2))
              vim.cmd 'wincmd j'
              vim.api.nvim_win_set_height(0, math.ceil(height / 2))
            end
          end)
        end,
      })
    end,
  },
  'tpope/vim-rhubarb',

  {
    'sindrets/diffview.nvim',
    -- TODO: Type opts.
    -- TODO: Add keymaps for the :Commit command.
    -- TODO: Make LSPs work in the main diff buffer. Either the buffer use the actual file or change
    -- LSP config to run in that buffer.
    config = function()
      local utils = require 'custom.utils'
      local diffview = require 'diffview'
      local actions = require('diffview.config').actions

      local keymaps_global = {
        ['<leader>e'] = actions.toggle_files,
        ['<leader>b'] = false,

        -- custom
        ['<leader>q'] = ':DiffviewClose<CR>',
      }

      diffview.setup {
        hooks = {
          --@ Attach gitsigns to the buffers. Only works when the main diff buffer is a real file,
          --@ not a state coming from .git/.
          diff_buf_read = function(buf)
            require('gitsigns').attach(buf)
          end,
        },

        view = {
          default = {
            layout = 'diff2_vertical',
          },
        },

        keymaps = {
          view = vim.tbl_extend('error', keymaps_global, {
            ['<C-k>'] = function()
              utils.preserve_cursor_column(function()
                vim.cmd 'normal! [c_'
              end)
            end,
            ['<C-j>'] = function()
              utils.preserve_cursor_column(function()
                vim.cmd 'normal! ]c_'
              end)
            end,
          }),
          file_panel = keymaps_global,
        },
      }
    end,
  },
}
