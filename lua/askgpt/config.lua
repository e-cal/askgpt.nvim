local M = {}
function M.defaults()
	local defaults = {
		default_prompt = {
			n = "Where is this from, what does it do, and how is it used? Show me an example.",
			v = "",
		},
		params = {
			model = "gpt-3.5-turbo",
			frequency_penalty = 0,
			presence_penalty = 0,
			max_tokens = 300,
			temperature = 0,
			top_p = 1,
			n = 1,
		},
		binds = {
			submit = "<C-d>",
			close = "q",
		},
	}
	return defaults
end

M.config = {}

function M.setup(options)
	options = options or {}
	M.config = vim.tbl_deep_extend("force", {}, M.defaults(), options)
end

return M
