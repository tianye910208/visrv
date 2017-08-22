print("[worker]init", SERVER_ID, WORKER_ID)
package.path = "?;?.lua;lua/?;lua/?.lua"

local srv = require("srv")
local decode = srv.decode
local encode = srv.encode
local printr = srv.printr
local mq_push = srv.push
local mq_pull = srv.pull


local sys = require("sys")
local modlist = sys.list

while true do
    local mq = table.pack(server.pull(WORKER_ID))
    if mq.n > 0 then
        for i,v in ipairs(mq) do
            mq_push(v)
        end
    end

    mq = mq_pull()
    if mq then
        for i,v in ipairs(mq) do
            local cmd = decode(v)
            local mod = modlist[cmd.mod]
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






