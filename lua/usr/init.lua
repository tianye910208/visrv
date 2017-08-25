
local mod = {}

mod.on_init = function(self, msg, src, req)
    log.i("[mod]on_init", src, msg)
    srv.cast(self.uid, self.uid, "test")
end

mod.on_exit = function(self, msg, src, req)
    log.i("[mod]on_exit", src, msg)

end

mod.on_recv = function(self, msg, src, req)
    log.i("[mod]["..srv.time.."]on_data", src, msg)
    if msg == "test" then
        log.i("wait0", srv.time)
        log.i(srv.call(self.uid, self.uid, "Hi"))
        log.i("wait1", srv.time)
        srv.wait(self.uid, 3000)
        log.i("wait2", srv.time)
        srv.cast(self.uid, self.uid, "HoldSend", 3000)
    elseif msg == "Hi" then
        log.i("echo1", srv.time)
        srv.wait(self.uid, 1000)
        log.i("echo2", srv.time)
        return "OK", "succ"
    end
end


return mod












