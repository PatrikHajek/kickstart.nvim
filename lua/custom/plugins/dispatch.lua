return {
  'tpope/vim-dispatch',
  lazy = false, -- It's lightweight enough to load on start
  cmd = { 'Dispatch', 'Make', 'Focus', 'Start' }, -- Or lazy-load on these commands
  config = function()
    -- Optional: Auto-open quickfix when a build finishes
    vim.g.dispatch_quickfix_height = 10

    --- List of compiler pipelines. Each pipeline runs it's compiler in the order of definition.
    --- @type { name: string, compilers: string[] }[]
    local pipelines = {
      { name = 'nuxi + eslint', compilers = { 'nuxi', 'eslint' } },
      { name = 'vue-tsc + eslint', compilers = { 'vue', 'eslint' } },
    }

    local function pick_compiler()
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      local options = {}
      vim.list_extend(options, pipelines)
      local compilers = vim.fn.getcompletion('', 'compiler')
      for _, v in ipairs(compilers) do
        table.insert(options, { name = v, compilers = { v } })
      end

      table.sort(options, function(a, b)
        return a.name:lower() < b.name:lower()
      end)

      pickers
        .new({}, {
          prompt_title = 'Select Compiler',
          finder = finders.new_table {
            results = options,
            entry_maker = function(entry)
              return { display = entry.name, value = entry, ordinal = entry.name }
            end,
          },
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry().value

              local combined_prg = {}
              local combined_efm = {}

              for _, c in ipairs(selection.compilers) do
                -- After calling `:compiler <name>`, errorformat and makeprg are set.
                vim.cmd('compiler ' .. c)
                local prg = vim.bo.makeprg
                table.insert(combined_prg, prg)
                local efm = vim.opt_local.errorformat:get()
                vim.list_extend(combined_efm, efm)
              end

              -- `;` in bash joins commands together even if the preceding failed.
              vim.opt_local.makeprg = table.concat(combined_prg, ' ; ')
              vim.opt_local.errorformat = combined_efm

              vim.cmd 'Make'
            end)
            return true
          end,
        })
        :find()
    end
    vim.keymap.set('n', '<leader>mc', pick_compiler, { desc = 'Run [M]ake using picked [C]ompiler' })
  end,
}
