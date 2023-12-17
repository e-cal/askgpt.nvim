local api = require("askgpt.api")
local ask = require("askgpt.ask")
local config = require("askgpt.config")

local M = {}

M.setup = function(opts)
	config.setup(opts)
	api.setup()
end

M.ask = function(opts)
	ask.ask(opts)
end

M.submit = function()
	ask.submit()
end

return M
