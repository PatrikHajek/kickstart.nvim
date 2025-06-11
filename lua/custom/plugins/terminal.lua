-- return {
-- 	'rebelot/terminal.nvim',
-- 	config = function()
-- 		require("terminal").setup({
-- 			layout = { open_cmd = 'float' },
-- 		})
--
-- 		-- Keymaps
-- 		local mappings = require("terminal.mappings")
-- 		vim.keymap.set({ "n", "x" }, "<leader>ts", mappings.operator_send, { expr = true })
-- 		vim.keymap.set("n", "<leader>to", mappings.toggle, { desc = "[T]erminal [O]pen in Float" })
-- 		vim.keymap.set("n", "<leader>tO", mappings.toggle({ open_cmd = "enew" }),
-- 			{ desc = "[T]erminal [O]pen in Fullscreen" })
-- 		vim.keymap.set("n", "<leader>tr", mappings.run, { desc = "[T]ermianl [R]un in Float" })
-- 		vim.keymap.set("n", "<leader>tR", mappings.run(nil, { layout = { open_cmd = "enew" } }),
-- 			{ desc = "[T]ermianl [R]un in Fullscreen" })
-- 		vim.keymap.set("n", "<leader>tk", mappings.kill, { desc = "[T]erminal [K]ill" })
-- 		vim.keymap.set("n", "<leader>t]", mappings.cycle_next, { desc = "[T]erminal Cycle Next" })
-- 		vim.keymap.set("n", "<leader>t[", mappings.cycle_prev, { desc = "[T]erminal Cycle Previous" })
-- 		-- vim.keymap.set("n", "<leader>tl", mappings.move({ open_cmd = "belowright vnew" }))
-- 		-- vim.keymap.set("n", "<leader>tL", mappings.move({ open_cmd = "botright vnew" }))
-- 		-- vim.keymap.set("n", "<leader>th", mappings.move({ open_cmd = "belowright new" }))
-- 		-- vim.keymap.set("n", "<leader>tH", mappings.move({ open_cmd = "botright new" }))
-- 		-- vim.keymap.set("n", "<leader>tf", mappings.move({ open_cmd = "float" }))
-- 	end
-- }
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      open_mapping = '<C-t>',
      direction = 'tab',
      auto_scroll = false,
      -- insert_mappings = false,
      -- shade_terminals = true,
      -- hide_numbers = false,

      -- autochdir = true,
    }

    -- mappings
    -- vim.keymap.set("n", "<leader>to", ":ToggleTerm direction=float<CR>", { desc = "Toggle Terminal in Floating Window" })
    -- vim.keymap.set("n", "<leader>tO", ":ToggleTerm direction=tab<CR>", { desc = "Toggle Terminal in Normal Mode" })
    vim.keymap.set('t', '<C-x>', '<esc><bar><C-\\><C-n>', { desc = 'Exit terminal mode' })

    -- [[ Working gf/gF in term ]]
    -- for keeping the original gf/gF functionality without having to make it myself
    vim.keymap.set('n', 'gabcf', 'gf')
    vim.keymap.set('n', 'gabcF', 'gF')

    -- TODO: make the params a union.

    ---@param with_num boolean | nil
    ---@param use_selection boolean | nil
    local function goto_file(with_num, use_selection)
      if vim.bo.buftype == 'terminal' then
        local line
        local path
        if use_selection then
          -- FIX: this does not work for visual-block
          vim.api.nvim_command ':normal v'
          line = require('custom.utils').get_selection()
          line = vim.trim(line:gsub('\n', ''))
          path = line
        else
          line = vim.api.nvim_get_current_line()
          path = vim.fn.expand '<cfile>'
        end
        assert(type(line) == 'string', 'line not set')
        assert(type(path) == 'string', 'path not set')

        vim.api.nvim_command ':q'
        vim.api.nvim_command(':e ' .. path)
        if with_num then
          -- TODO: better message
          assert(use_selection == false, 'cannot set cursor position using selection')
          local _, last = line:find(path, 0, true)
          if last then
            local tail = line:sub(last + 1, line:len())
            local lnum = tonumber(tail:match '%d+')
            if lnum == nil then
              return
            end
            local col = tonumber(tail:match '%d+%:(%d+)') or 0
            col = col > 0 and col - 1 or 0
            vim.api.nvim_win_set_cursor(0, { lnum, col })
          end
        end
        return
      end

      if with_num then
        vim.api.nvim_command 'normal gabcF'
      else
        vim.api.nvim_command 'normal gabcf'
      end
    end
    vim.keymap.set('n', 'gf', function()
      goto_file(true)
    end, { noremap = true, desc = 'Jump to file under cursor' })
    vim.keymap.set('n', 'gF', function()
      goto_file()
    end, { noremap = true, desc = 'Jump to file under cursor without cursor position' })
    vim.keymap.set('x', 'gf', function()
      goto_file(false, true)
    end, { noremap = true, desc = 'Jump to file using current selection' })
  end,
}
