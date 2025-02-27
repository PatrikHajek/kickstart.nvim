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
      direction = 'float',
      insert_mappings = false,
      shade_terminals = true,
      hide_numbers = false,
    }

    -- mappings
    -- vim.keymap.set("n", "<leader>to", ":ToggleTerm direction=float<CR>", { desc = "Toggle Terminal in Floating Window" })
    -- vim.keymap.set("n", "<leader>tO", ":ToggleTerm direction=tab<CR>", { desc = "Toggle Terminal in Normal Mode" })
    vim.keymap.set('t', '<C-x>', '<esc><bar><C-\\><C-n>', { desc = 'Exit terminal mode' })
  end,
}
