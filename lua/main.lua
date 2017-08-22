package.path = "?;?.lua;lua/?;lua/?.lua"

local util = require("util")
local decode = util.decode
local encode = util.encode
local printr = util.printr


local list = {}

list[0] = {
    on_recv = function(self, src, req, msg)
        if msg[1] == "fork" then
            local cls = require(msg[2])
            local idx = msg[3] or (#list+1)
            local mod = setmetatable({}, {__index = cls})
            mod.uid = {SERVER_ID, WORKER_ID, idx}
            mod:on_init(from, msg[4])
            return mod.uid
        elseif msg[1] == "exit" then
            local uid = msg[2]
            local mid = uid and uid[3]
            local mod = mid and list[mid]
            if mod then
                list[mid] = nil
                mod:on_exit(from, msg[3])
            end
        end
    end
}


while true do
    local mq = table.pack(server.pull(WORKER_ID))
    if mq.n > 0 then
        for i,v in ipairs(mq) do
            local cmd = decode(v)
            local mod = list[cmd.mod]
            if mod then
                mod:on_recv(cmd.src, cmd.req, cmd.msg)
            else
                print("[worker]cmd mod miss")
                printr(cmd)
            end
        end
    else
        server.wait(10);
    end
end






