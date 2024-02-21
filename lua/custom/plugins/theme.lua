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

-- onedarkpro
return {
	"olimorris/onedarkpro.nvim",
	priority = 1000, -- Ensure it loads first
	--[[ config = function()
		require("onedarkpro").setup({
			options = {
				-- consider enabling (underlines same words)
				-- cursorline = true
			}
		})
	end ]]
}
