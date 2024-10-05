-- return {
-- 	"github/copilot.vim"
-- }

return {
  'zbirenbaum/copilot.lua',
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = false,
      hide_during_completion = false,
      debounce = 0,
      filetypes = {
        markdown = true,
        help = true,
      },
      keymap = {
        accept = '<C-l>',
        next = '<C-j>',
        prev = '<C-k>',
      },
    },
  },
}
