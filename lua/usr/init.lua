
local mod = {}

mod.on_init = function(self, src, msg)
    log.i("[mod]on_init", src, msg)
    local req = srv.reqn()
    srv.send(self.uid, req, self.uid, "Hi")
    print(select(2, assert(coroutine.yield(req))))
end

mod.on_exit = function(self, src, msg)
    log.i("[mod]on_exit", src, msg)

end

mod.on_recv = function(self, src, msg)
    log.i("[mod]on_data", src, msg)
    log.i(dat.tostr(msg))
    return "OK", "succ"
end


return mod












