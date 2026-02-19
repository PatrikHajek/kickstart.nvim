-- To inspect highlight groups and used colors, you can use `:Inspect`.

-- onedarkpro
return {
  'olimorris/onedarkpro.nvim',
  priority = 1000, -- Ensure it loads first
  config = function()
    local colors = require('onedarkpro.helpers').get_colors 'onedark_vivid'
    require('onedarkpro').setup {
      -- NOTE: for a list of possible values, run `h attr-list`
      highlights = {
        -- TelescopeSelection was set to purple fg and black bg before upgrading. Currently, when
        -- setting fg, it will overwrite the TelescopeMatching - won't highlight matched chars.
        TelescopeMatching = { fg = colors.purple, bold = true },
        TelescopeSelection = { bg = colors.black },

        ['@markup.list.checked.markdown'] = { fg = colors.purple },
        SpellBad = { fg = colors.green },
        SpellLocal = { fg = colors.green },
        -- SpellBad = { underdashed = true },

        -- Scala
        ['@lsp.type.parameter.scala'] = { link = '@variable.parameter' },
        ['@lsp.typemod.variable.readonly.scala'] = {},
        ['@lsp.type.namespace.scala'] = { link = '@constant' },
      },
    }
    vim.cmd 'colorscheme onedark_vivid'
  end,
}

-- onedark
-- return {
-- 	-- Theme inspired by Atom
-- 	'navarasu/onedark.nvim',
-- 	priority = 1000,
-- 	lazy = false,
-- 	config = function()
-- 		require('onedark').setup {
-- 			-- Set a style preset. 'dark' is default.
-- 			style = 'dark', -- dark, darker, cool, deep, warm, warmer, light
-- 		}
-- 		require('onedark').load()
-- 	end,
-- }

-- catpuccin
-- return {
-- 	"catppuccin/nvim", name = "catppuccin", priority = 1000
-- }

-- kanagawa
-- return {
-- 	"rebelot/kanagawa.nvim"
-- }

-- ayu
-- return {
-- 	"Shatur/neovim-ayu"
-- }

-- embark
-- return {
-- 	'embark-theme/vim', as = 'embark'
-- }

-- oxocarbon
-- return {
-- 	"nyoom-engineering/oxocarbon.nvim"
-- }
