require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Image display mappings
map("n", "<leader>ie", "<cmd>lua require('image').enable()<cr>", { desc = "Enable image display" })
map("n", "<leader>id", "<cmd>lua require('image').disable()<cr>", { desc = "Disable image display" })
map("n", "<leader>ic", "<cmd>lua require('image').clear()<cr>", { desc = "Clear all images" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
