
local mod = {}

mod.uid = {SERVER_ID, WORKER_ID, 0}
mod.cnt = 0
mod.idx = 1001
mod.map = {}
mod.map[0] = mod

mod.on_recv = function(self, msg, src, req)
    local func = self[msg[1]]
    if func then
        return func(self, msg, src, req)
    end
end


mod.fork = function(self, msg, src, req)
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
        srv.send(src, req, {sid, wid, 0}, msg)
        return nil
    end

    if not mid then
        mid = self.idx
        self.idx = self.idx + 1
    end

    if self.map[mid] then
        return nil
    end

    local mod = setmetatable({}, {__index = cls})
    mod.uid = {SERVER_ID, WORKER_ID, mid}
    mod:on_init(msg[4], src, req)

    self.map[mid] = mod
    self.cnt = self.cnt + 1

    return mod.uid
end

mod.exit = function(self, msg, src, req)
    local uid = msg[2]
    local mid = uid and uid[3]
    local mod = mid and self.map[mid]
    if mod then
        self.map[mid] = nil
        self.cnt = self.cnt - 1

        mod:on_exit(msg[3], src, req)
    end
end

mod.send = function(self, msg, src, req)
    local sid, wid, msg = msg[1], msg[2], msg[3]


end

return mod







