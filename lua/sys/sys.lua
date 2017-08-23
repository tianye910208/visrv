print("[worker]init", SERVER_ID, WORKER_ID)
package.path = "?;?.lua;lua/?;lua/?.lua"

math.randomseed(os.time())

dat = require("sys/dat")
srv = require("sys/srv")

local _G = _G
local _GG = {}
for k,v in pairs(_G) do
    _GG[k] = v
end
for k,v in pairs(_GG) do
    _G[k] = nil
end
_GG.setmetatable(_G, {
    __index = _GG,
    __newindex = function(t, k, v)
        error("set global failed: "..tostring(k).."="..tostring(v))
    end
})


local decode = dat.decode
local encode = dat.encode
local printr = dat.printr
local mq_push = srv.push
local mq_pull = srv.pull


local mod_run = require("sys/run")
local mod_map = mod_run.map

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

            local mod = mod_map[v.mid]
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






