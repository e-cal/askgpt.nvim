local M = {}
function M.defaults()
	local defaults = {
		params = {
			model = "gpt-4-0613",
			frequency_penalty = 0,
			presence_penalty = 0,
			max_tokens = 300,
			temperature = 0,
			top_p = 1,
			n = 1,
		},
		keymap = {
            ask = "<C-g>",
			submit = "<cr>",
			close = "q",
		},
		split_size = 15,
		vsplit_size = 15,
	}
	return defaults
end

M.config = {}

function M.setup(options)
	options = options or {}
	M.config = vim.tbl_deep_extend("force", {}, M.defaults(), options)
end

return M
