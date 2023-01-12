return function(use)
	--	use({
	--	'github/copilot.vim',
	--	config = function()
	--		require("copilot").setup({})
	--	end
	-- })
	use({
		'zbirenbaum/copilot.lua',
		event = "VimEnter",
		config = function()
			vim.defer_fn(function()
				require("copilot").setup()
			end, 100)
		end
	})
	use({
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end
	})

	-- Fish syntax support
	use("khaveesh/vim-fish-syntax")
end
