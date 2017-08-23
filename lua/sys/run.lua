
local mod = {}

mod.uid = {SERVER_ID, WORKER_ID, 0}
mod.cnt = 0
mod.idx = 1001
mod.map = {}
mod.map[0] = mod

mod.on_recv = function(self, src, msg)
    local func = self[msg[1]]
    if func then
        return func(self, src, msg)
    end
end


mod.fork = function(self, src, msg)
    local cls = require(msg[2])
    if not cls then
        return nil
    end
    local mid = msg[3]
    if not mid then
        mid = self.idx
        self.idx = self.idx + 1
    end

    local mod = setmetatable({}, {__index = cls})
    mod.uid = {SERVER_ID, WORKER_ID, mid}
    mod:on_init(from, msg[4])

    self.map[mid] = mod
    self.cnt = self.cnt + 1

    return mod.uid
end

mod.exit = function(self, src, msg)
    local uid = msg[2]
    local mid = uid and uid[3]
    local mod = mid and self.map[mid]
    if mod then
        self.map[mid] = nil
        self.cnt = self.cnt - 1

        mod:on_exit(src, msg[3])
    end
end

mod.send = function(self, src, msg)
    local sid, wid, msg = msg[1], msg[2], msg[3]


end

return mod







