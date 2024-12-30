-- [text-case.nvim](https://github.com/johmsalas/text-case.nvim)

-- WARN: might conflict with mini.ai if set up incorrectly

-- TODO: make `-` the same as `_`
-- kebab-case should be selected the same way snake_case is -> `viw` selecting
-- the whole word and `vis` selecting subwords

return {
  {
    'chrisgrieser/nvim-spider',
    lazy = true,
    keys = {
      {
        'w',
        "<cmd>lua require('spider').motion('w')<CR>",
        mode = { 'n', 'o', 'x' },
      },
      {
        'e',
        "<cmd>lua require('spider').motion('e')<CR>",
        mode = { 'n', 'o', 'x' },
      },
      {
        'b',
        "<cmd>lua require('spider').motion('b')<CR>",
        mode = { 'n', 'o', 'x' },
      },
    },
  },
  {
    'chrisgrieser/nvim-various-textobjs',
    config = function()
      -- TODO: indentation
      -- TODO: key-value pairs

      -- subword
      vim.keymap.set({ 'o', 'x' }, 'as', '<cmd>lua require("various-textobjs").subword("outer")<CR>', { desc = '[S]ubword' })
      vim.keymap.set({ 'o', 'x' }, 'is', '<cmd>lua require("various-textobjs").subword("inner")<CR>', { desc = '[S]ubword' })
      -- url
      vim.keymap.set({ 'o', 'x' }, 'au', '<cmd>lua require("various-textobjs").url("outer")<CR>', { desc = '[U]RL' })
      vim.keymap.set({ 'o', 'x' }, 'iu', '<cmd>lua require("various-textobjs").url("inner")<CR>', { desc = '[U]RL' })
      -- mdEmphasis
      vim.keymap.set({ 'o', 'x' }, 'ae', '<cmd>lua require("various-textobjs").mdEmphasis("outer")<CR>', { desc = 'Markdown [E]mphasis' })
      vim.keymap.set({ 'o', 'x' }, 'ie', '<cmd>lua require("various-textobjs").mdEmphasis("inner")<CR>', { desc = 'Markdown [E]mphasis' })
      -- htmlAttribute
      vim.keymap.set({ 'o', 'x' }, 'ax', '<cmd>lua require("various-textobjs").htmlAttribute("outer")<CR>', { desc = 'HTML attribute' })
      vim.keymap.set({ 'o', 'x' }, 'ix', '<cmd>lua require("various-textobjs").htmlAttribute("inner")<CR>', { desc = 'HTML attribute' })
    end,
  },
}
