local M = {
	"catppuccin/nvim",
	priority = 1000,
	lazy = false
}

function M.config()
	vim.cmd.colorscheme("catppuccin-mocha")
end

return M
