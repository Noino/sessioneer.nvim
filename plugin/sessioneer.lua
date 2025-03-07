if vim.g.loaded_sessioneer then
    return
end

vim.cmd([[command! SessionStart :lua require("sessioneer").start()]])
vim.cmd([[command! SessionStop :lua require("sessioneer").stop()]])

local S = require("sessioneer")

vim.api.nvim_create_autocmd("VimEnter", {
    nested = true,
    callback = S.autoload,
})

vim.g.loaded_sessioneer = true
