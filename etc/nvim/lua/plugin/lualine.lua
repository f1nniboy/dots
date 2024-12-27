local M = {
	"nvim-lualine/lualine.nvim",
	lazy = false
}

function M.config()
	require("lualine").setup {
	  options = {
	    icons_enabled = true,
	    theme = "auto",
	    component_separators = { left = "|", right = "|"},
	    section_separators = { left = "", right = ""},
	    disabled_filetypes = {
	      statusline = {},
	      winbar = {},
	    },
	    ignore_focus = {},
	    always_divide_middle = true,
	    always_show_tabline = true,
	    globalstatus = false,
	    refresh = {
	      statusline = 50,
	      tabline = 50,
	      winbar = 50,
	    }
	  },
	  sections = {
	    lualine_a = {'mode'},
	    lualine_b = {'branch', 'diff', 'diagnostics'},
	    lualine_c = {'filename'},
	    lualine_x = {'filetype'},
	    lualine_y = {'progress'},
	    lualine_z = {'location'}
	  },
	  inactive_sections = {
	    lualine_a = {},
	    lualine_b = {},
	    lualine_c = {'filename'},
	    lualine_x = {'location'},
	    lualine_y = {},
	    lualine_z = {}
	  },
	  tabline = {},
	  winbar = {},
	  inactive_winbar = {},
	  extensions = {}
	}
end

return M
