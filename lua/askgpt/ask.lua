local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local api = require("askgpt.api")
local utils = require("askgpt.utils")
local config = require("askgpt.config")

local M = {}

M.ask = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local mode = vim.api.nvim_get_mode().mode
	local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
	local buf_params = vim.lsp.util.make_position_params()

	local popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
		},
		position = "50%",
		size = {
			width = "75%",
			height = "60%",
		},
		text = {
			top = "AskGPT",
		},
	})

	-- mount/open the component
	popup:mount()
	local width = vim.api.nvim_win_get_width(0)
	vim.api.nvim_buf_set_option(popup.bufnr, "textwidth", width)

	-- unmount component when cursor leaves buffer
	popup:on(event.BufLeave, function()
		popup:unmount()
	end)

	-- mappings
	popup:map("n", config.config.binds.close, function()
		popup:unmount()
	end)
	for _, m in ipairs({ "n", "i" }) do
		popup:map(m, config.config.binds.submit, function()
			local lines = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
			local prompt = table.concat(lines, "\n")
			local params = { messages = { { role = "user", content = prompt } } }
			api.chat(params, function(res)
				local res_txt = utils.split_string_by_line(res)
				local current_lines = vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
				table.insert(current_lines, "---")
				table.insert(res_txt, "---")
				vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, vim.list_extend(current_lines, res_txt))
			end)
		end)
	end

	-- set content
	if mode == "n" then
		utils.get_hover_text(bufnr, buf_params, function(htext)
			if htext then
				local lines = vim.split(htext, "\n", true)
				table.insert(lines, config.config.default_prompt.n)
				vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, lines)
			end
		end)
	elseif mode == "v" or mode == "V" then
		local lines = utils.get_visual_lines(bufnr)
		table.insert(lines, 1, "```" .. filetype)
		table.insert(lines, "```")
		table.insert(lines, config.config.default_prompt.v)
		vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, lines)
	else
		return
	end
end

return M
