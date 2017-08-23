
local mod = {}

mod.on_init = function(self, src, msg)
    log.i("[mod]on_init", src, msg)
    srv.send(self.uid, nil, self.uid, "Hi")
end

mod.on_exit = function(self, src, msg)
    log.i("[mod]on_exit", src, msg)

end

mod.on_recv = function(self, src, msg)
    log.i("[mod]on_data", src, msg)
    log.i(dat.tostr(msg))
end


return mod












