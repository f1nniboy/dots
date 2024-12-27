vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>pf", builtin.find_files)
vim.keymap.set("n", "<C-g>", builtin.git_files)
vim.keymap.set("n", "<leader>ps", function()
   builtin.grep_string ({search = vim.fn.input("grep > ")})
end)

-- undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- lsp
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename)
