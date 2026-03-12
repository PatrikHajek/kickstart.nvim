return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<Nop>',
          node_incremental = '<C-l>',
          scope_incremental = '<TAB>',
          node_decremental = '<C-h>',
        },
      },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    opts = {
      move = {
        set_jumps = true,
      },
    },
    init = function()
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      vim.g.no_plugin_maps = true

      -- [[ Repeat ]]
      local ts_repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'

      -- Repeat movement with ; and ,
      -- ensure ; goes forward and , goes backward regardless of the last direction
      vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

      -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
      vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })

      -- [[ Move ]]
      local jump_to_parent_context = ts_repeat_move.make_repeatable_move(function()
        local ts_utils = require 'nvim-treesitter.ts_utils'
        local node = ts_utils.get_node_at_cursor()
        if not node then
          return
        end

        local context_types = {
          'function_declaration',
          'function_definition',
          'method_declaration',
          'class_declaration',
          'if_statement',
          'for_statement',
          'while_statement',
          'arrow_function',
          'function',

          -- Markdown
          'section',
        }

        local parent = node:parent()
        while parent do
          if vim.tbl_contains(context_types, parent:type()) then
            vim.cmd 'normal! m`'
            local start_row, start_col = parent:range()
            vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
            return
          end
          parent = parent:parent()
        end
        print 'No parent context found'
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, '<leader>tk', function()
        jump_to_parent_context { forward = true }
      end, { desc = 'Jump to parent context' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@statement.outer', 'textobjects')
      end, { desc = 'Next statement' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[s', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@statement.outer', 'textobjects')
      end, { desc = 'Previous statement' })

      vim.keymap.set('n', ']z', ']s', { desc = 'Next misspelled word' })
      vim.keymap.set('n', '[z', '[s', { desc = 'Previous misspelled word' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'Next function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'Previous function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
      end, { desc = 'Next function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
      end, { desc = 'Previous function end' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']o', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@loop.outer', 'textobjects')
      end, { desc = 'Next loop start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[o', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@loop.outer', 'textobjects')
      end, { desc = 'Previous loop start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']O', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@loop.outer', 'textobjects')
      end, { desc = 'Next loop end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[O', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@loop.outer', 'textobjects')
      end, { desc = 'Previous loop end' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']c', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@conditional.outer', 'textobjects')
      end, { desc = 'Next condition start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[c', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@conditional.outer', 'textobjects')
      end, { desc = 'Previous condition start' })

      -- [[ Select ]]
      vim.keymap.set({ 'x', 'o' }, 'as', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@statement.outer', 'textobjects')
      end, { desc = 'statement' })

      vim.keymap.set({ 'x', 'o' }, 'ab', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
      end, { desc = 'code block (scope)' })

      vim.keymap.set({ 'x', 'o' }, 'am', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
      end, { desc = 'function' })
      vim.keymap.set({ 'x', 'o' }, 'im', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
      end, { desc = 'function' })

      vim.keymap.set({ 'x', 'o' }, 'aa', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
      end, { desc = 'parameter' })
      vim.keymap.set({ 'x', 'o' }, 'ia', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
      end, { desc = 'parameter' })

      vim.keymap.set({ 'x', 'o' }, 'ao', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@loop.outer', 'textobjects')
      end, { desc = 'loop' })
      vim.keymap.set({ 'x', 'o' }, 'io', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@loop.inner', 'textobjects')
      end, { desc = 'loop' })

      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@conditional.outer', 'textobjects')
      end, { desc = 'conditional' })
      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@conditional.inner', 'textobjects')
      end, { desc = 'conditional' })

      vim.keymap.set({ 'x', 'o' }, 'a=', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@assignment.outer', 'textobjects')
      end, { desc = 'assignment' })
      vim.keymap.set({ 'x', 'o' }, 'i=', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@assignment.inner', 'textobjects')
      end, { desc = 'assignment' })
      vim.keymap.set({ 'x', 'o' }, 'in=', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@assignment.rhs', 'textobjects')
      end, { desc = 'rhs of assignment' })
      vim.keymap.set({ 'x', 'o' }, 'il=', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@assignment.lhs', 'textobjects')
      end, { desc = 'lhs of assignment' })

      -- [[ Swap ]]
      vim.keymap.set('n', '<leader>ta', function()
        require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
      end, { desc = 'Swap parameter with the next one' })
      vim.keymap.set('n', '<leader>tA', function()
        require('nvim-treesitter-textobjects.swap').swap_previous '@parameter.outer'
      end, { desc = 'Swap parameter with the previous one' })
    end,
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup {
        n_lines = 500,
        search_method = 'cover',
      }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      -- require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  {
    'stevearc/aerial.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
      'kiyoon/repeatable-move.nvim',
    },
    opts = {},
    init = function()
      local repeat_move = require 'repeatable_move'

      local aerial_next, aerial_prev = repeat_move.make_repeatable_move_pair(function()
        vim.cmd 'AerialNext'
      end, function()
        vim.cmd 'AerialPrev'
      end)
      vim.keymap.set({ 'n', 'x', 'o' }, ']a', aerial_next, { desc = 'Next Aerial symbol' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[a', aerial_prev, { desc = 'Previous Aerial symbol' })

      vim.keymap.set('n', '<leader>an', ':AerialNavToggle<CR>', { desc = 'Open [A]erial [N]av' })
    end,
  },
}
