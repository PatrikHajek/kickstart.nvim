--- Get the commit count difference between target and HEAD.
--- @param target string
--- @return integer
local function get_commit_count(target)
  local cmd = ('git rev-list --count %s..HEAD'):format(target)
  local count = vim.fn.system(cmd):gsub('%s+', '')
  return tonumber(count) or 0
end

--- Get the commit hash.
--- @param commits_left integer Must be greater than 0.
--- @return string
local function get_commit_diff_hash(commits_left)
  assert(commits_left > 0, 'There must be at least 1 commit left to open diff.')
  return ('HEAD~%i..HEAD~%i'):format(commits_left - 1, commits_left)
end

--- Get the commit hash.
--- @param commits_left integer
--- @return string
local function get_commit_hash(commits_left)
  return ('HEAD~%i'):format(commits_left)
end

local commit_count --- @type integer
local commits_left --- @type integer

--- Initialize the state.
--- @param target string
local function init(target)
  -- TODO: Move initialization into first.
  commit_count = get_commit_count(target)
  commits_left = commit_count
end
init 'origin/HEAD'

--- Open diff against the adjacent commits.
local function open_diff()
  vim.cmd 'DiffviewClose'
  vim.cmd('DiffviewOpen ' .. get_commit_diff_hash(commits_left))
  print(('Commit HEAD~%i / %i'):format(commits_left, commit_count))
end

local function show()
  local hash = get_commit_hash(commits_left)
  -- `-s` suppresses diff.
  vim.cmd('G show -s ' .. hash)
end

--- @type table<string, fun(args: string[])>
local commands = {
  init = function(args)
    -- TODO: Validate?
    local target = args[1]
    init(target)
  end,

  next = function()
    if commits_left > 1 then
      commits_left = commits_left - 1
      open_diff()
    else
      print 'Reached the last commit'
    end
  end,

  prev = function()
    commits_left = commits_left + 1
    open_diff()
  end,

  first = function()
    commits_left = commit_count
    open_diff()
  end,

  last = function()
    commits_left = 1
    open_diff()
  end,

  diff = function()
    open_diff()
  end,

  show = show,
}

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
    end,
  },
  'tpope/vim-rhubarb',

  {
    'sindrets/diffview.nvim',
    -- TODO: Type opts.
    -- TODO: Change default keymaps.
    -- TODO: Put toggling sidebar to `<leader>e`.
    -- TODO: Quit using `<leader>q`.
    -- TODO: Keymap to jump into main diff.
    -- TODO: Add keymaps for the :Commit command.
    opts = {
      view = {
        default = {
          layout = 'diff2_vertical',
        },
      },
    },
  },
}
