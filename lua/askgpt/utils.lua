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

	local start_row, start_col = unpack(vim.api.nvim_buf_get_mark(bufnr, "<"))
	local end_row, end_col = unpack(vim.api.nvim_buf_get_mark(bufnr, ">"))
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row - 1, end_row, false)

	-- use 1-based indexing and handle selections made in visual line mode
	start_col = start_col + 1
	end_col = math.min(end_col, #lines[#lines] - 1) + 1

	-- shorten first/last line according to start_col/end_col
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

return M
