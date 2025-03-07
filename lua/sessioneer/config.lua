local defaults = {
    auto_restore = true,                                  -- automatically restore session when opening a directory
    session_dir = vim.fn.stdpath('data') .. '/sessions/', -- custom session storage directory
    git_branches = true,
    log_level = "warn",
}

local M = {
    config = vim.deepcopy(defaults),
}

M.setup = function(opts)
    opts = opts or {}
    M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts)
end

return setmetatable(M, {
    __index = function(_, key)
        if key == "setup" then
            return M.setup
        end
        return rawget(M.config, key)
    end,
})
