
local mod = {}

mod.on_init = function(self, msg, src, req)
    log.i("[mod]on_init", src, msg)
    srv.cast(self.uid, self.uid, "test")
end

mod.on_exit = function(self, msg, src, req)
    log.i("[mod]on_exit", src, msg)

end

mod.on_recv = function(self, msg, src, req)
    log.i("[mod]on_data", src, msg)
    if msg == "test" then
        log.i(srv.call(self.uid, self.uid, "Hi"))
    elseif msg == "Hi" then
        return "OK", "succ"
    end
end


return mod












