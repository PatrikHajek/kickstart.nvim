return {
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
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

      -- [[ Textobjects ]]
      require('which-key').add {
        { ']', group = 'Go to next textobject' },
        { '[', group = 'Go to previous textobject' },
        { '^', group = 'Go to enclosing textobject' },
      }

      --- @param textobject string
      --- @param key_start string | false
      --- @param key_end string | false
      --- @param key_around string | false
      --- @param key_inner string | false
      --- @param key_enclosing_start (string | false)?
      --- @param key_enclosing_end (string | false)?
      --- @param opts { name: string? }?
      local function map(textobject, key_start, key_end, key_around, key_inner, key_enclosing_start, key_enclosing_end, opts)
        local ts_move = require 'nvim-treesitter-textobjects.move'
        local ts_select = require 'nvim-treesitter-textobjects.select'
        local move = require 'custom.plugins.treesitter.move'

        key_enclosing_start = key_enclosing_start ~= nil and key_enclosing_start or key_start
        key_enclosing_end = key_enclosing_end ~= nil and key_enclosing_end or key_end

        opts = opts or {}
        opts.name = opts.name or textobject

        if key_start then
          vim.keymap.set({ 'n', 'x', 'o' }, ']' .. key_start, function()
            ts_move.goto_next_start('@' .. textobject .. '.outer', 'textobjects')
          end, { desc = 'Next ' .. opts.name .. ' start' })
          vim.keymap.set({ 'n', 'x', 'o' }, '[' .. key_start, function()
            ts_move.goto_previous_start('@' .. textobject .. '.outer', 'textobjects')
          end, { desc = 'Previous ' .. opts.name .. ' start' })
        end

        if key_end then
          vim.keymap.set({ 'n', 'x', 'o' }, ']' .. key_end, function()
            ts_move.goto_next_end('@' .. textobject .. '.outer', 'textobjects')
          end, { desc = 'Next ' .. opts.name .. ' end' })
          vim.keymap.set({ 'n', 'x', 'o' }, '[' .. key_end, function()
            ts_move.goto_previous_end('@' .. textobject .. '.outer', 'textobjects')
          end, { desc = 'Previous ' .. opts.name .. ' end' })
        end

        if key_around then
          vim.keymap.set({ 'x', 'o' }, 'a' .. key_around, function()
            vim.cmd 'normal! m`'
            ts_select.select_textobject('@' .. textobject .. '.outer', 'textobjects')
          end, { desc = opts.name })
        end

        if key_inner then
          vim.keymap.set({ 'x', 'o' }, 'i' .. key_inner, function()
            vim.cmd 'normal! m`'
            ts_select.select_textobject('@' .. textobject .. '.inner', 'textobjects')
          end, { desc = opts.name })
        end

        if key_enclosing_start then
          vim.keymap.set({ 'n', 'x', 'o' }, '^' .. key_enclosing_start, function()
            move.goto_enclosing_start({ forward = true }, { query_files = { 'textobjects' }, captures = { textobject .. '.outer' } })
          end, { desc = 'Enclosing ' .. opts.name .. ' start' })
        end

        if key_enclosing_end then
          vim.keymap.set({ 'n', 'x', 'o' }, '^' .. key_enclosing_end, function()
            move.goto_enclosing_end({ forward = true }, { query_files = { 'textobjects' }, captures = { textobject .. '.outer' } })
          end, { desc = 'Enclosing ' .. opts.name .. ' end' })
        end
      end

      local QUERY_FILES = {
        'indents',
      }
      local CAPTURES = {
        'indent.begin',
      }

      local move = require 'custom.plugins.treesitter.move'
      vim.keymap.set({ 'n', 'x', 'o' }, '<leader>tk', function()
        move.goto_enclosing { forward = true }
      end, { desc = 'Jump to parent context' })

      map('statement', 's', false, 's', false)
      vim.keymap.set('n', ']z', ']s', { desc = 'Next misspelled word' })
      vim.keymap.set('n', '[z', '[s', { desc = 'Previous misspelled word' })

      map('function', 'm', 'M', 'm', 'm')

      map('loop', 'o', 'O', 'o', 'o')

      map('conditional', 'c', 'C', 'c', 'c')

      map('comment', 'n', false, false, false, false, false)

      vim.keymap.set({ 'x', 'o' }, 'ab', function()
        vim.cmd 'normal! m`'
        require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
      end, { desc = 'code block (scope)' })

      map('assignment', false, false, '=', '=', '=')
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
        custom_textobjects = {
          -- Used by treesitter.
          ['s'] = false,
          ['b'] = false,
          ['m'] = false,
          ['o'] = false,
          ['c'] = false,
          ['='] = false,
        },
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
