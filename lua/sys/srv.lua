
local mod = {}

mod.uid = {SERVER_ID, WORKER_ID, 0}
mod.cnt = 0
mod.map = {}
mod.map[0] = mod
mod.time = 0

local worker_idx = 1001
local worker_req = 0
local worker_ret = {"SKIP"}
local worker_bin = {}
local worker_mq1 = {{mid=mod.uid[3], msg={"_init"}}}
local worker_mq2 = {}
local worker_mqt = {}

mod.req = function()
    worker_req = worker_req + 1
    return worker_req
end

mod.ret = function()
    return worker_ret
end

mod.push = function(cmd)
    table.insert(worker_mq1, cmd)
end

mod.pull = function()
    if next(worker_mq1) then
        worker_mq1, worker_mq2 = worker_mq2, worker_mq1
        return worker_mq2
    end
    return nil 
end

mod.fork = function(src, req, cls, arg, sid, wid, mid)
    local msg = {"_fork", cls, arg, mid}
    mod.send(src, req, {sid or SERVER_ID, wid or 255, 0}, msg)
    if src and req then
        return select(2, assert(coroutine.yield(req)))
    end
end

mod.exit = function(src, req, uid, arg)
    local sid, wid, mid = uid[1], uid[2], uid[3]
    local msg = {"_exit", mid, arg}
    mod.send(src, req, {sid, wid, 0}, msg)
    if src and req then
        return select(2, assert(coroutine.yield(req)))
    end
end

mod.send = function(src, req, uid, msg)
    local sid, wid, mid = uid[1], uid[2], uid[3]
    local cmd = {
        mid = mid,
        src = src,
        req = req,
        msg = msg,
    }

    if sid ~= SERVER_ID then
        mod.push({
            mid = 0,
            msg = {"_send", sid, wid, cmd},
        })
    elseif wid == WORKER_ID then
        mod.push(cmd)
    else
        if wid == 255 then
            wid = server.rand()
        end
        local bin = dat.encode(cmd)
        local ret = server.push(wid, bin)
        if ret == 0 then
            worker_bin[wid] = {}
        end
        local map = worker_bin[wid]
        if not map then
            map = {}
            worker_bin[wid] = map
        end
        table.insert(map, bin)
    end
end

mod.cast = function(src, uid, msg)
    mod.send(src, nil, uid, msg)
end

mod.call = function(src, uid, msg)
    local req = mod.req()
    mod.send(src, req, uid, msg)
    return select(2, assert(coroutine.yield(req)))
end

mod.wait = function(src, sec)
    local msg = {"_wait", sec}
    return mod.call(src, mod.uid, msg)
end


--srv mod--
mod.on_recv = function(self, msg, src, req)
    local func = self[msg[1]]
    if func then
        return func(self, msg, src, req)
    end
end


local _loop_msg = {"_loop"}
mod._init = function(self, msg, src, req)
    mod.send(nil, nil, self.uid, _loop_msg)
end

mod._loop = function(self, msg, src, req)
    mod.send(nil, nil, self.uid, _loop_msg)
    server.wait(10)
    local t = server.time()
    mod.time = t

    print("time", t)

end

mod._wait = function(self, msg, src, req)
    local t = mod.time + msg
    local m = {t, src, req}
    for i,v in ipairs(worker_mqt) do
        if t < v[1] then
            table.insert(worker_mqt, i, m)
            m = nil
            break
        end
    end
    if m then
        table.insert(worker_mqt, i, m)
    end
    return mod.ret()
end

mod._fork = function(self, msg, src, req)
    local cls = require(msg[2])
    if not cls then
        return nil
    end

    local sid, wid, mid = SERVER_ID, WORKER_ID, msg[3]
    if cls.uid then
        sid = cls.uid[1] or sid
        wid = cls.uid[2] or wid
        mid = cls.uid[3] or mid
    end

    if sid ~= SERVER_ID or wid ~= WORKER_ID then
        mod.send(src, req, {sid, wid, 0}, msg)
        return nil
    end

    if not mid then
        mid = worker_idx
        worker_idx = worker_idx + 1
    end

    if self.map[mid] then
        if cls.uid == nil then
            print("[srv][fork] mod is running:", msg[2])
        end
        return nil
    end

    local mod = setmetatable({}, {__index = cls})
    mod.uid = {SERVER_ID, WORKER_ID, mid}
    mod:on_init(msg[4], src, req)

    self.map[mid] = mod
    self.cnt = self.cnt + 1

    return mod.uid
end

mod._exit = function(self, msg, src, req)
    local uid = msg[2]
    local mid = uid and uid[3]
    local mod = mid and self.map[mid]
    if mod then
        self.map[mid] = nil
        self.cnt = self.cnt - 1

        mod:on_exit(msg[3], src, req)
    end
end

mod._send = function(self, msg, src, req)
    local sid, wid, msg = msg[1], msg[2], msg[3]


end


return mod




