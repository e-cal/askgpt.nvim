local cmd = vim.api.nvim_create_user_command
local askgpt = require("askgpt")

cmd("Ask", function(opts)
	askgpt.ask(opts)
end, { nargs = "*", range = true })

cmd("AskSubmit", function()
	askgpt.submit()
end, {})
