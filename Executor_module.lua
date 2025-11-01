-- executor_module.lua
-- Safe API wrapper. Put allowed logic here.
local M = {}

-- Example: M.Execute should call your permitted logic.
-- 'opts' is a table: { users = {...}, min_rap = number, webhook = string, mailMessage = string }
function M.Execute(opts)
    -- Validate input
    if type(opts) ~= "table" then
        warn("[ExecutorModule] Execute called with invalid opts")
        return
    end

    -- Put authorized, safe actions here.
    -- For example: update local UI, log, simulate behavior, call allowed module functions.
    print("[ExecutorModule] Execute called with opts:", opts)

    -- Example safe action: fire a BindableEvent for logging or status updates
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local logEvent = ReplicatedStorage:FindFirstChild("ScriptControlEvent_Log")
    if logEvent and logEvent:IsA("BindableEvent") then
        pcall(function() logEvent:Fire("Execute called. users=" .. tostring(#(opts.users or {}))) end)
    end

    -- Return true on success, false or error message on failure
    return true
end

return M
