
local mod = {}

mod.uid = {SERVER_ID, WORKER_ID, 0}
mod.list = {}
mod.list[0] = mod

mod.on_recv = function(self, src, req, msg)
    local func = self[msg[1]]
    if func then
        func(self, src, req, msg)
    end
end


mod.fork = function(self, src, req, msg)
    local cls = require(msg[2])
    local mid = msg[3] or (#self.list+1)
    local mod = setmetatable({}, {__index = cls})
    mod.uid = {SERVER_ID, WORKER_ID, mid}
    mod:on_init(from, msg[4])

    self.list[mid] = mod
    return mod.uid
end

mod.exit = function(self, src, req, msg)
    local uid = msg[2]
    local mid = uid and uid[3]
    local mod = mid and self.list[mid]
    if mod then
        self.list[mid] = nil
        mod:on_exit(from, msg[3])
    end
end

mod.send = function(self, src, req, msg)
    local sid, wid, msg = msg[1], msg[2], msg[3]


end

return mod







