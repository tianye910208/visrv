package.path = "?;?.lua;lua/?;lua/?.lua"
math.randomseed(os.time())
server.wait(100*WORKER_ID)
print("[worker]init", SERVER_ID, WORKER_ID)

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


local srv_map = srv.map
local req_map = {}
local bin_map = {}
local bin_idx = 1
local bin_max = 0xffff

srv.fork(nil, nil, "sys/log", nil, SERVER_ID, WORKER_ID)
srv.fork(nil, nil, "usr/init", nil, SERVER_ID, WORKER_ID)

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

            local co, ret, req
            if v.req and v.src == nil then
                co = req_map[v.req]
                if co then
                    req_map[v.req] = nil
                    ret, req = coroutine.resume(co, table.unpack(v.msg))
                else
                    req = "req miss "..v.req
                end
            else
                local mod = srv_map[v.mid]
                if mod then
                    co = coroutine.create(function()
                        if v.req then
                            local ret = {true, mod:on_recv(v.msg, v.src, v.req)}
                            if ret[2] ~= srv.ret() then
                                srv.send(nil, v.req, v.src, ret)
                            end
                        else
                            mod:on_recv(v.msg, v.src)
                        end
                    end)
                    ret, req = coroutine.resume(co)
                else
                    req = "mod miss "..v.mid
                end
            end

            if ret then
                if req then
                    req_map[req] = co
                end
            else
                if v.req and v.src ~= nil then
                    srv.send(nil, v.req, v.src, {false, req})
                end
                print("[E][worker]run fail:"..tostring(req))
                print(dat.tostr(v))
            end
        end
    else
        server.wait(10);
    end
end






