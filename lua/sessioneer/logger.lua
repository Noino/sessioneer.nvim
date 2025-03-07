-- This file is shamelessly yoinked from rmagatti/auto-session
--
-- MIT License
--
-- Copyright (c) 2021 Ronnie Magatti
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
--


local Logger = {}

---Function that handles vararg printing, so logs are consistent.
local function to_print(...)
    local args = { ... }

    for i, value in ipairs(args) do
        if type(value) ~= "string" then
            args[i] = vim.inspect(value)
        end
    end

    return vim.fn.join(args, " ")
end

function Logger:new(obj_and_config)
    obj_and_config = obj_and_config or {}

    self = vim.tbl_deep_extend("force", self, obj_and_config)
    self.__index = function(_, index)
        if type(self[index]) == "function" then
            return function(...)
                -- Make it so any call to logger with "." dot access for a function results in the syntactic sugar of ":" colon access
                self[index](self, ...)
            end
        else
            return self[index]
        end
    end

    setmetatable(obj_and_config, self)

    return obj_and_config
end

function Logger:debug(...)
    if self.log_level == "debug" or self.log_level == vim.log.levels.DEBUG then
        vim.notify("sessioneer.nvim DEBUG: " .. to_print(...), vim.log.levels.DEBUG)
    end
end

function Logger:info(...)
    local valid_values = { "info", "debug", vim.log.levels.DEBUG, vim.log.levels.INFO }

    if vim.tbl_contains(valid_values, self.log_level) then
        vim.notify("sessioneer.nvim INFO: " .. to_print(...), vim.log.levels.INFO)
    end
end

function Logger:warn(...)
    local valid_values = { "info", "debug", "warn", vim.log.levels.DEBUG, vim.log.levels.INFO, vim.log.levels.WARN }

    if vim.tbl_contains(valid_values, self.log_level) then
        vim.notify("sessioneer.nvim WARN: " .. to_print(...), vim.log.levels.WARN)
    end
end

function Logger:error(...)
    vim.notify("sessioneer.nvim ERROR: " .. to_print(...), vim.log.levels.ERROR)
end

return Logger
