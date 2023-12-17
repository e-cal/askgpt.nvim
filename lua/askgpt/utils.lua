local M = {}

local ESC_FEEDKEY = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

function M.get_hover_text(bufnr, params, cb)
	local hover_text = ""
	vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
		if err or not result then
			cb(nil)
			return
		end

		if not result.contents then
			cb(nil)
			return
		end

		if type(result.contents) == "string" then
			hover_text = result.contents
		elseif type(result.contents) == "table" then
			hover_text = result.contents.value
		end

		cb(hover_text)
	end)
end

function M.get_visual_lines(bufnr)
	vim.api.nvim_feedkeys(ESC_FEEDKEY, "n", true)
	vim.api.nvim_feedkeys("gv", "x", false)
	vim.api.nvim_feedkeys(ESC_FEEDKEY, "n", true)

	local start_row, start_col = table.unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
	local end_row, end_col = table.unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row - 1, end_row, false)

	start_col = start_col + 1
	end_col = math.min(end_col, #lines[#lines] - 1) + 1

	lines[#lines] = lines[#lines]:sub(1, end_col)
	lines[1] = lines[1]:sub(start_col)

	return lines
end

function M.split_string_by_line(text)
	local lines = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		table.insert(lines, line)
	end
	return lines
end

function M.get_ask_buf()
	local ask_buf = nil
	for _, _bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(_bufnr):match("askgptbuf$") then
			ask_buf = _bufnr
			break
		end
	end
    return ask_buf
end

return M
