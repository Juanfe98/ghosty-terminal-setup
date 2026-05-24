-- Extra keymaps
-- ============================================================================
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { silent = true, desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = true, desc = "Quit" })
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<cr>", { silent = true, desc = "Clear search" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Down window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Up window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Right window" })

vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<cr>", { silent = true, desc = "Resize -height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<cr>", { silent = true, desc = "Resize +height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { silent = true, desc = "Resize -width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { silent = true, desc = "Resize +width" })

vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { silent = true, desc = "Prev buffer" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "<leader>sv", function()
	local ft = vim.bo.filetype
	vim.cmd("vnew")
	vim.bo.swapfile = false
	vim.bo.bufhidden = "wipe"
	vim.bo.buftype = ""
	vim.cmd("setlocal filetype=" .. ft)
end, { desc = "Scratch vsplit (match filetype)" })

vim.keymap.set("n", "<leader>bb", require("telescope.builtin").buffers, {
	desc = "Open recent buffers",
})

vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })

vim.keymap.set("n", "<leader>bd", function()
	local current = vim.api.nvim_get_current_buf()
	vim.cmd("bprevious")
	if vim.api.nvim_get_current_buf() == current then
		vim.cmd("enew")
	end
	vim.cmd("bdelete " .. current)
end, { silent = true, desc = "Delete buffer safely" })

vim.keymap.set("n", "<leader>cp", function()
	local path = vim.fn.expand("%") -- path relative to cwd
	vim.fn.setreg("+", path)
	vim.notify("Copied to clipboard " .. path)
end, { desc = "Copy relative file path" })

