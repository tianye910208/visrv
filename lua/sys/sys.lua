print("[worker]init", SERVER_ID, WORKER_ID)
package.path = "?;?.lua;lua/?;lua/?.lua"

math.randomseed(os.time())

dat = require("sys/dat")
srv = require("sys/srv")
log = require("sys/log")

local _G = _G
local _P = {}
for k,v in pairs(_G) do
    _P[k] = v
end
for k,v in pairs(_P) do
    _G[k] = nil
end
_P.setmetatable(_G, {
    __index = _P,
    __newindex = function(t, k, v)
        error("set global failed: "..tostring(k).."="..tostring(v))
    end
})


local decode = dat.decode
local encode = dat.encode
local mq_push = srv.push
local mq_pull = srv.pull


local mod_run = require("sys/run")
local mod_map = mod_run.map
local req_map = {}

if WORKER_ID == 0 then
    srv.fork(nil, nil, "sys/log", nil, SERVER_ID, WORKER_ID)
end
srv.fork(nil, nil, "usr/init", nil, SERVER_ID, WORKER_ID)

server.wait(200*WORKER_ID)
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

            local ret, req
            if v.req and v.src == nil then
                local co = req_map[v.req]
                if co then
                    req_map[v.req] = nil
                    ret, req = coroutine.resume(co, table.unpack(v.msg))
                else
                    print("[worker]req miss")
                    print(dat.tostr(v))
                end
            else
                local mod = mod_map[v.mid]
                if mod then
                    local co = coroutine.create(function()
                        if v.req then
                            local ret = {mod:on_recv(v.msg, v.src, v.req)}
                            srv.send(nil, v.req, v.src, ret)
                        else
                            mod:on_recv(v.msg, v.src)
                        end
                    end)
                    ret, req = coroutine.resume(co)
                else
                    print("[worker]mod miss")
                    print(dat.tostr(v))
                end
            end

            if ret then
                if req then
                    req_map[req] = co
                end
            end
        end
    else
        server.wait(10);
    end
end






