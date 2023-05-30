local cmd = vim.api.nvim_create_user_command
local askgpt = require("askgpt")

cmd("Ask", askgpt.ask, {})
