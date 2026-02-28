-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      numhl = true,
      attach_to_untracked = true,
      diff_opts = { vertical = false },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        --- Map a keybind and, after running it, preserve cursor column position.
        --- @param mode string
        --- @param l string
        --- @param r function
        --- @param opts table
        local function map_preserve(mode, l, r, opts)
          map(mode, l, function()
            require('custom.utils').preserve_cursor_column(r)
          end, opts)
        end

        -- [[ Navigation ]]
        map_preserve('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c_', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map_preserve('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c_', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        map_preserve('n', '<C-j>', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c_', bang = true }
          else
            --- LSP errors, but help pages show that the fields are optional.
            --- @diagnostic disable-next-line: missing-fields
            gitsigns.nav_hunk('next', { target = 'all', wrap = false })
          end
        end, { desc = 'Jump to next hunk' })

        map_preserve('n', '<C-k>', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c_', bang = true }
          else
            --- LSP errors, but help pages show that the fields are optional.
            --- @diagnostic disable-next-line: missing-fields
            gitsigns.nav_hunk('prev', { target = 'all', wrap = false })
          end
        end, { desc = 'Jump to previous hunk' })

        -- [[ Actions ]]
        map('n', '<leader>hs', function()
          if vim.wo.diff then
            vim.cmd ':diffput'
          else
            gitsigns.stage_hunk()
          end
        end, { desc = 'git [s]tage hunk' })

        map('n', '<leader>hr', function()
          if vim.wo.diff then
            vim.cmd ':diffget'
          else
            gitsigns.reset_hunk()
          end
        end, { desc = 'git [r]eset hunk' })

        map('v', '<leader>hs', function()
          if vim.wo.diff then
            vim.cmd 'normal! \27' -- <ESC> char
            vim.cmd "'<,'>diffput"
          else
            vim.api.nvim_command ':normal! m0'
            gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
            vim.api.nvim_command ':normal! `0'
          end
        end, { desc = 'stage git hunk' })

        map('v', '<leader>hr', function()
          if vim.wo.diff then
            vim.cmd 'normal! \27' -- <ESC> char
            vim.cmd "'<,'>diffget"
          else
            vim.api.nvim_command ':normal! m0'
            gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
            vim.api.nvim_command ':normal! `0'
          end
        end, { desc = 'reset git hunk' })

        map('n', '<leader>hU', function()
          if vim.wo.diff then
            vim.api.nvim_echo({ { 'use `:%diffput <buffer-number>` instead' } }, false, {})
          else
            gitsigns.reset_buffer_index()
          end
        end, { desc = 'git [U]nstage buffer' })

        map('n', '<leader>hR', function()
          if vim.wo.diff then
            vim.api.nvim_echo({ { 'use `:%diffget <buffer-number>` instead' } }, false, {})
          else
            gitsigns.reset_buffer()
          end
        end, { desc = 'git [R]eset buffer' })

        -- [[ Preview ]]
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
        map('n', '<leader>hb', function()
          gitsigns.blame_line { full = true }
        end)

        -- [[ Selection ]]
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'git select hunk' })

        -- [[ Diff ]]
        map('n', '<leader>hd', function()
          local unstaged_hunks = gitsigns.get_hunks(vim.api.nvim_get_current_buf())
          if #unstaged_hunks == 0 then
            vim.api.nvim_echo({ { 'No hunks' } }, false, {})
            return
          end
          gitsigns.diffthis()
        end, { desc = 'git [d]iff against index' })

        map('n', '<leader>hDc', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last [c]ommit' })

        map('n', '<leader>hDh', function()
          gitsigns.diffthis '~'
        end, { desc = 'git [D]iff against [h]ead' })

        -- [[ Toggles ]]
        map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git [w]ord diff' })
      end,
    },
  },
}
