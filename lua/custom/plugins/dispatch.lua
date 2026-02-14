return {
  'tpope/vim-dispatch',
  lazy = false, -- It's lightweight enough to load on start
  cmd = { 'Dispatch', 'Make', 'Focus', 'Start' }, -- Or lazy-load on these commands
  config = function()
    -- Optional: Auto-open quickfix when a build finishes
    vim.g.dispatch_quickfix_height = 10

    local function pick_compiler()
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      -- Get all installed compilers
      local compilers = vim.fn.getcompletion('', 'compiler')

      pickers
        .new({}, {
          prompt_title = 'Select Compiler',
          finder = finders.new_table { results = compilers },
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()

              -- 1. Set the compiler
              vim.cmd('compiler ' .. selection[1])
              -- 2. Run Make (via vim-dispatch)
              vim.cmd 'Make'

              print('Switched to ' .. selection[1] .. ' and started :Make')
            end)
            return true
          end,
        })
        :find()
    end
    vim.keymap.set('n', '<leader>mc', pick_compiler, { desc = 'Run [M]ake using picked [C]ompiler' })
  end,
}
