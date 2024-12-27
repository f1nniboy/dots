local M = {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"nvim-lua/plenary.nvim"
	}
}

M.servers = {
	"lua_ls",
	"clangd",
	"bashls"
}

function M.config()
	local lsp = require("lsp-zero")
	lsp.preset("recommended")

	lsp.set_preferences({
		suggest_lsp_servers = false
	})

	require("lsp-zero").setup()
	require("mason").setup()

	require("mason-lspconfig").setup_handlers {
		function (server_name)
			require "lspconfig" [server_name].setup({})
		end
	}

	require("mason-lspconfig").setup {
		ensure_installed = M.servers,
		automatic_installation = true
	}

    vim.diagnostic.config({
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = ""
		},

		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = 'E',
				[vim.diagnostic.severity.WARN] = 'W',
				[vim.diagnostic.severity.INFO] = 'I',
				[vim.diagnostic.severity.HINT] = 'H'
			}
		}
	})
end

return M
