local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local api = require("askgpt.api")
local utils = require("askgpt.utils")
local config = require("askgpt.config")

local M = {}

M.submit = function()
	local bufnr = utils.get_ask_buf()
	if bufnr == nil then
		print("No ask buffer")
		return
	end
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local prompt = table.concat(lines, "\n")
	local params = { messages = { { role = "user", content = prompt } } }
	api.chat(params, function(res)
		local res_txt = utils.split_string_by_line(res)
		local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		table.insert(current_lines, "--------------------------------------------------------------------------------")
		table.insert(res_txt, "--------------------------------------------------------------------------------")
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.list_extend(current_lines, res_txt))
	end)
end

M.ask = function(opts)
	local bufnr = vim.api.nvim_get_current_buf()
	local mode = vim.api.nvim_get_mode().mode
	local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

    local lines = {}
	if mode == "v" or mode == "V" then
        lines = utils.get_visual_lines(bufnr)
		table.insert(lines, 1, "```" .. filetype)
		table.insert(lines, "```")
	elseif opts.range > 0 then
		lines = vim.api.nvim_buf_get_lines(bufnr, opts.start - 1, opts.stop, false)
		table.insert(lines, 1, "```" .. filetype)
		table.insert(lines, "```")
	end

	-- Make buffer
	local ask_buf = utils.get_ask_buf()
	if ask_buf == nil then
		ask_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(ask_buf, "askgptbuf")
		vim.api.nvim_buf_set_option(ask_buf, "buftype", "nofile")
	end

	-- Focus buffer
	if vim.fn.bufwinnr(ask_buf) == -1 then
		if opts.args == "v" then
			vim.api.nvim_command(config.config.vsplit_size .. "vsplit")
		else
			vim.api.nvim_command(config.config.split_size .. "split")
		end
		vim.api.nvim_win_set_buf(0, ask_buf)

		vim.api.nvim_buf_set_keymap(
			ask_buf,
			"n",
			config.config.keymap.close,
			"<cmd>q<cr>",
			{ noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(
			ask_buf,
			"n",
			config.config.keymap.ask,
			"<cmd>q<cr>",
			{ noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(
			ask_buf,
			"n",
			config.config.keymap.submit,
			"<cmd>AskSubmit<cr>",
			{ noremap = true, silent = true }
		)
    else
        local all_wins = vim.fn.win_findbuf(ask_buf)
        local winid = all_wins[1]
        vim.api.nvim_set_current_win(winid)
	end

    vim.api.nvim_buf_set_lines(ask_buf, -1, -1, false, lines)
end

return M
