--- Get the commit count difference between target and HEAD.
--- @param target string
--- @return integer
local function get_commit_count(target)
  local cmd = ('git rev-list --count %s..HEAD'):format(target)
  local count = vim.fn.system(cmd):gsub('%s+', '')
  return tonumber(count) or 0
end

--- Get the commit hash.
--- @param commits_left integer
--- @return string
local function get_commit_diff_hash(commits_left)
  return ('HEAD~%i..HEAD~%i'):format(commits_left - 1, commits_left)
end

--- Get the commit hash.
--- @param commits_left integer
--- @return string
local function get_commit_hash(commits_left)
  return ('HEAD~%i'):format(commits_left)
end

--- Open diff against the adjacent commits.
--- @param commits_left integer
local function open_diff(commits_left)
  vim.cmd('DiffviewOpen ' .. get_commit_diff_hash(commits_left))
  print(commits_left .. ' commits left')
end

-- TODO: Option to specify optional target.
local commit_count = get_commit_count 'origin/dev'
local commits_left = commit_count

-- TODO: Add autocomplete.
-- FIX: Calling `:Commit show` closes diff.
vim.api.nvim_create_user_command('Commit', function(args)
  vim.cmd 'DiffviewClose'
  if args.fargs[1] == 'next' then
    commits_left = commits_left - 1
    open_diff(commits_left)
  elseif args.fargs[1] == 'prev' then
    commits_left = commits_left + 1
    open_diff(commits_left)
  elseif args.fargs[1] == 'first' then
    commits_left = commit_count
    open_diff(commits_left)
  elseif args.fargs[1] == 'last' then
    commits_left = 1
    open_diff(commits_left)
  elseif args.fargs[1] == 'diff' then
    open_diff(commits_left)
  elseif args.fargs[1] == 'show' then
    local hash = get_commit_hash(commits_left)
    -- `-s` suppresses diff.
    vim.cmd('G show -s ' .. hash)
  else
    print 'Not a command'
  end
end, { desc = 'See introduced changes commit by commit', nargs = 1 })

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
    opts = {
      view = {
        default = {
          layout = 'diff2_vertical',
        },
      },
    },
  },
}
