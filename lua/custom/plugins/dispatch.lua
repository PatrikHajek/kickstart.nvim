return {
  'tpope/vim-dispatch',
  lazy = false, -- It's lightweight enough to load on start
  cmd = { 'Dispatch', 'Make', 'Focus', 'Start' }, -- Or lazy-load on these commands
  config = function()
    -- Optional: Auto-open quickfix when a build finishes
    vim.g.dispatch_quickfix_height = 10
  end,
}
