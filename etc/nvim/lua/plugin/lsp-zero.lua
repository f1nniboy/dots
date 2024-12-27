local M = {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v1.x",
	dependencies = {
		-- lsp support
		'neovim/nvim-lspconfig',

		-- auto-completion
		'hrsh7th/nvim-cmp',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-path',
		'saadparwaiz1/cmp_luasnip',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-nvim-lua'
	}
}

return M
