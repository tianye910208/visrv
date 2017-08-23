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
            mq_push(decode(v))
        end
    end

    mq = mq_pull()
    if mq then
        for i = 1, #mq do
            local v = mq[i]
            mq[i] = nil

            local mod = modlist[v.mod]
            if mod then
                mod:on_recv(v.src, v.msg)
            else
                print("[worker]mod miss")
                printr(v)
            end
        end
    else
        server.wait(10);
    end
end






