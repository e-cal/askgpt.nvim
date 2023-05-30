local job = require("plenary.job")
local config = require("askgpt.config")

local M = {}

M.CHAT_URL = "https://api.openai.com/v1/chat/completions"

function M.chat(extra_params, cb)
	local params = vim.tbl_extend("keep", extra_params, config.config.params)
	M.curl(M.CHAT_URL, params, cb)
end

function M.curl(url, params, cb)
	TMP = os.tmpname()
	local f = io.open(TMP, "w+")
	if f == nil then
		vim.notify("Error opening tmp file " .. TMP, vim.log.levels.ERROR)
		return
	end
	f:write(vim.fn.json_encode(params))
	f:close()

	M.job = job:new({
		command = "curl",
		args = {
			url,
			"-H",
			"Content-Type: application/json",
			"-H",
			"Authorization: Bearer " .. M.OPENAI_API_KEY,
			"-d",
			"@" .. TMP,
		},
		on_exit = vim.schedule_wrap(function(res, exit_code)
			M.handle_response(res, exit_code, cb)
		end),
	}):start()
end

M.handle_response = vim.schedule_wrap(function(res, exit_code, cb)
	os.remove(TMP)
	if exit_code ~= 0 then
		vim.notify("Error: " .. res, vim.log.levels.ERROR)
		cb("API Error")
		return
	end

	local result = table.concat(res:result(), "\n")
	local json = vim.fn.json_decode(result)
	if json == nil then
		cb("No response.")
	elseif json.error then
		cb("API Error: " .. json.error.message)
	else
		local message = json.choices[1].message
		if message then
			local res_text = message.content
			if type(res_text) == "string" and res_text ~= "" then
				cb(res_text, json.usage)
			else
				cb("Non-text response.")
			end
		else
			local res_text = json.choices[1].text
			if type(res_text) == "string" and res_text ~= "" then
				cb(res_text, json.usage)
			else
				cb("Non-text response.")
			end
		end
	end
end)

function M.close()
	if M.job then
		job:shutdown()
	end
end

function M.setup()
	M.OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
	if not M.OPENAI_API_KEY then
		local cache_file = vim.fn.expand("~/.cache/nvim/oai")
		local api_key
		if vim.fn.filereadable(cache_file) == 1 then
			api_key = vim.fn.readfile(cache_file)[1]
		else
			api_key = vim.fn.input("API Key: ")
			if api_key and api_key ~= "" then
				vim.fn.mkdir(vim.fn.expand("~/.cache/nvim"), "p") -- Create the directory if it doesn't exist
				vim.fn.writefile({ api_key }, cache_file)
			else
				print("No key")
				return
			end
		end
		M.OPENAI_API_KEY = api_key
	end
	M.OPENAI_API_KEY = M.OPENAI_API_KEY:gsub("%s+$", "")
end

return M
