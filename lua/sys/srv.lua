local co_yield = coroutine.yield
local t_insert = table.insert


local srv = {}

srv.uid = {SERVER_ID, WORKER_ID, 0}
srv.cnt = 0
srv.map = {}
srv.map[0] = srv
srv.time = 0

local worker_idx = 1001
local worker_req = 0
local worker_ret = {"SKIP"}
local worker_mq1 = {}
local worker_mq2 = {}
local worker_mqt = {}


local worker_bin_use = {}
local worker_bin_old = {}
local worker_bin_rec = 0

srv.req = function()
    worker_req = worker_req + 1
    return worker_req
end

srv.ret = function()
    return worker_ret
end

srv.push = function(cmd)
    t_insert(worker_mq1, cmd)
end

srv.pull = function()
    worker_mq1, worker_mq2 = worker_mq2, worker_mq1
    return worker_mq2
end

srv.fork = function(src, req, mod, arg, sid, wid, mid)
    local msg = {"_fork", mod, arg, mid}
    srv.send(src, req, {sid or SERVER_ID, wid or 255, 0}, msg)
    if src and req then
        return select(2, assert(co_yield(req)))
    end
end

srv.exit = function(src, req, uid, arg)
    uid = uid or src
    local sid, wid, mid = uid[1], uid[2], uid[3]
    local msg = {"_exit", mid, arg}
    srv.send(src, req, {sid, wid, 0}, msg)
    if src and req then
        return select(2, assert(co_yield(req)))
    end
end

srv.send = function(src, req, uid, msg)
    local sid, wid, mid = uid[1], uid[2], uid[3]
    local cmd = {
        mid = mid,
        src = src,
        req = req,
        msg = msg,
    }

    if sid ~= SERVER_ID then
        srv.push({
            mid = 0,
            msg = {"_send", sid, wid, cmd},
        })
    elseif wid == WORKER_ID then
        srv.push(cmd)
    else
        if wid == 255 then
            wid = server.rand()
        end
        local bin = dat.encode(cmd)
        server.push(wid, bin)

        local cache = worker_bin_use[wid]
        if not cache then
            cache = {}
            worker_bin_use[wid] = cache
        end
        t_insert(cache, bin)
    end
end

srv.cast = function(src, uid, msg, msec)
    if msec then
        local sms = {"_wait", msec, uid, msg}
        srv.send(src, nil, srv.uid, sms)
    else
        srv.send(src, nil, uid, msg)
    end
end

srv.call = function(src, uid, msg)
    local req = srv.req()
    srv.send(src, req, uid, msg)
    return select(2, assert(co_yield(req)))
end

srv.wait = function(src, msec)
    local sms = {"_wait", msec}
    return srv.call(src, srv.uid, sms)
end

srv.tick = function(time)
    if time < srv.time then
        srv.time = srv.time - 0xffffffff
        for i,v in ipairs(worker_mqt) do
            v[1] = v[1] - 0xffffffff
        end
        worker_bin_rec = worker_bin_rec - 0xffffffff
    end

    srv.time = time

    if time - worker_bin_rec > 8000 then
        worker_bin_rec = time
        worker_bin_old = worker_bin_use
        worker_bin_use = {}
    end

    for i = #worker_mqt, 1, -1 do
        local v = worker_mqt[i]
        if v[1] > time then
            break
        else
            worker_mqt[i] = nil
            local src,req,uid,msg = v[2],v[3],v[4],v[5]
            if req then
                srv.send(nil, req, uid, {true, msg})
            else
                srv.send(src, req, uid, msg)
            end
        end
    end

end

--srv mod--
srv.on_recv = function(self, msg, src, req)
    local func = self[msg[1]]
    if func then
        return func(self, msg, src, req)
    end
end

srv._wait = function(self, msg, src, req)
    local msec, uid, msg = msg[2], msg[3], msg[4]

    local t = srv.time + msec
    local m = {t, src, req, uid or src, msg}
    for i,v in ipairs(worker_mqt) do
        if t >= v[1] then
            t_insert(worker_mqt, i, m)
            m = nil
            break
        end
    end
    if m then
        t_insert(worker_mqt, m)
    end
    return srv.ret()
end

srv._fork = function(self, msg, src, req)
    local mod = env.require_mod(msg[2])
    if not mod then
        return nil
    end

    local sid, wid, mid = SERVER_ID, WORKER_ID, msg[3]
    if mod.uid then
        sid = mod.uid[1] or sid
        wid = mod.uid[2] or wid
        mid = mod.uid[3] or mid
    end

    if sid ~= SERVER_ID or wid ~= WORKER_ID then
        srv.send(src, req, {sid, wid, 0}, msg)
        return srv.ret()
    end

    if not mid then
        mid = worker_idx
        worker_idx = worker_idx + 1
    end

    if self.map[mid] then
        if mod.uid == nil then
            print("[srv][fork] mod is running:", msg[2])
        end
        return self.map[mid].uid
    end

    mod.uid = {SERVER_ID, WORKER_ID, mid}
    mod:on_init(msg[4], src, req)

    self.map[mid] = mod
    self.cnt = self.cnt + 1

    return mod.uid
end

srv._exit = function(self, msg, src, req)
    local mid = msg[2]
    local mod = mid and self.map[mid]
    if mod then
        self.map[mid] = nil
        self.cnt = self.cnt - 1

        mod:on_exit(msg[3], src, req)
    end
end

srv._send = function(self, msg, src, req)
    local sid, wid, msg = msg[1], msg[2], msg[3]


end


return srv




