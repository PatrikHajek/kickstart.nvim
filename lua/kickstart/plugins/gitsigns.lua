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

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        map('n', '<C-j>', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk('next', { target = 'all', wrap = false })
          end
        end, { desc = 'Jump to next hunk' })

        map('n', '<C-k>', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk('prev', { target = 'all', wrap = false })
          end
        end, { desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
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
        -- normal mode
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
        -- map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        -- map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
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

        -- Preview
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
        map('n', '<leader>hb', function()
          gitsigns.blame_line { full = true }
        end)

        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'git select hunk' })

        -- Diff
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

        map('n', '<leader>hq', function()
          gitsigns.setqflist 'all'
        end, { desc = 'git push [h]unks to [q]flist' })

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
        map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = '[T]oggle git [w]ord diff' })
        map('n', '<leader>gm', function()
          gitsigns.toggle_linehl()
          gitsigns.toggle_deleted()
          gitsigns.toggle_word_diff()
        end, { desc = '[T]oggle Buffer [G]it Diff [M]ode' })
      end,
    },
  },
}
