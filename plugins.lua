return {
	--	use({
	--	'github/copilot.vim',
	--	config = function()
	--		require("copilot").setup({})
	--	end
	-- })
	{
		'zbirenbaum/copilot.lua',
		event = "VimEnter",
		config = function()
			vim.defer_fn(function()
				require("copilot").setup()
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
	"khaveesh/vim-fish-syntax"
}
