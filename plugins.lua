return {
	-- {
	-- 'github/copilot.vim',
	-- config = function()
	-- 	require("copilot").setup({})
	-- end
	-- },
	{
		'zbirenbaum/copilot.lua',
		event = "VimEnter",
		config = function()
			vim.defer_fn(function()
				require("copilot").setup({
					suggestion = { enabled = false },
					panel = { enabled = false },
				})
			end, 100)
		end
	},
	{
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end
	},

	-- Fish syntax support
	"khaveesh/vim-fish-syntax",
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end
	}

}
