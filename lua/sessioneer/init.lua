local config = require "sessioneer.config"
local Logger = require "sessioneer.logger"

L = Logger:new { config.log_level or "warn" }

local M = {}

function M.path_to_filename(text)
    L.debug("Converting path to filename: " .. text)
    local ret = text:gsub("/+", "%%")
    L.debug("Converting path to filename result: " .. ret)
    return ret
end

local seshnode = (function()
    local sn = ''
    if not vim.g.started_with_stdin then
        if vim.fn.argc() == 0 then
            sn = vim.fn.getcwd()
        elseif vim.fn.isdirectory(vim.fn.argv(0)) ~= 0 then
            sn = vim.fn.fnamemodify(vim.fn.argv(0), ':p:h')
        end
    end
    L.debug("Session node: " .. sn)
    return sn
end)()

function M.branch()
    if seshnode ~= "" then
        local branch = vim.fn.systemlist("git -C " .. seshnode .. " branch --show-current")[1]
        return vim.v.shell_error == 0 and branch or ""
    end
end

function M.get_seshname()
    if seshnode == "" then return "" end
    local b = ""
    if config.git_branches then
        b = M.branch() or "";
        if b ~= "" then
            b = '@' .. b
        end
    end
    L.debug("Session name: " .. config.session_dir .. M.path_to_filename(seshnode) .. b .. ".vim")

    return config.session_dir .. M.path_to_filename(seshnode) .. ".vim"
end

local seshname = M.get_seshname()



function M.fire(event)
    L.debug("Firing event: " .. event)
    vim.api.nvim_exec_autocmds("User", { pattern = "sessioneer." .. event })
end

function M.autoload()
    L.debug("autoloading " .. seshnode)
    if seshnode ~= "" and config.auto_restore then
        L.debug("still autoloading")
        if not M.load() then
            L.warn("Load failed!")
        end
        M.start()
    end
end

function M.load(opts)
    opts = opts or {}

    if seshname == "" or vim.fn.filereadable(seshname) == 0 then
        L.debug("couldnt load " .. seshname)
        return false
    end

    if seshname and vim.fn.filereadable(seshname) ~= 0 then
        L.debug("Loading session: " .. seshname)
        vim.g.sessioneer_session = seshname
        M.fire("LoadPre")
        local initbuf = vim.api.nvim_list_bufs()

        vim.cmd("silent! source " .. vim.fn.fnameescape(seshname))

        vim.defer_fn(function()
            for _, buf in ipairs(initbuf) do
                if vim.api.nvim_buf_is_valid(buf) then
                    L.debug("Closing buffer " .. buf .. " as its not part of this session")
                    vim.api.nvim_buf_delete(buf, {})
                end
            end

            local bufname = vim.api.nvim_buf_get_name(0)
            if bufname ~= "" and vim.fn.filereadable(bufname) ~= 0 then
                vim.cmd("edit")
            else
                L.debug("Skipping edit: No valid file in the first buffer")
            end
        end, 10)

        M.fire("LoadPost")
        return true
    else
        L.debug("Couldnt load session")
        return false
    end
end

function M.start()
    if seshnode == "" then return end
    L.debug("Starting session tracking")
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufDelete", "BufWipeout", "VimLeavePre", "QuitPre" }, {
        group = vim.api.nvim_create_augroup("sessioneer", { clear = true }),
        callback = M.save,
    })
    vim.g.seshscribing = true
    M.fire("Start")
end

function M.stop()
    L.debug("Stopping session tracking")
    vim.g.seshscribing = false
    pcall(vim.api.nvim_del_augroup_by_name, "sessioneer")
    M.fire("Stop")
end

function M.save()
    L.debug("Attempting to save session")
    if seshnode == "" or not vim.g.seshscribing then return end

    L.debug("Saving seshname: " .. seshname)
    M.fire("SavePre")
    vim.cmd("mks! " .. vim.fn.fnameescape(seshname))
    M.fire("SavePost")
end

function M.toggle()
    M.fire("Toggle")
    if seshnode == "" then return end
    if vim.g.seshscribing then
        vim.g.seshscribing = false
        return M.stop()
    end
    return M.start()
end

function M.setup(opts)
    config.setup(opts)
    vim.fn.mkdir(config.session_dir, "p")
    L.debug("Wanna start seshscribing...")
    if not (config.auto_restore) and not vim.g.seshscribing then
        M.start()
    end
end

function string:endswith(suffix)
    return self:sub(- #suffix) == suffix
end

return M
