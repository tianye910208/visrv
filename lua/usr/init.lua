local mod = {}

mod.on_init = function(self, msg, src, req)
    log.i("[mod]on_init", src, msg)
    cast(self.uid, "test")
end

mod.on_exit = function(self, msg, src, req)
    log.i("[mod]on_exit", src, msg)

end

mod.on_recv = function(self, msg, src, req)
    log.i("[mod]["..time().."]on_data", src, msg)
    if msg == "test" then
        log.i("wait0", time())
        log.i(call(self.uid, "Hi"))
        log.i("wait1", time())
        wait(3000)
        log.i("wait2", time())
        cast(self.uid, "HoldSend", 3000)
    elseif msg == "Hi" then
        log.i("echo1", time())
        wait(1000)
        log.i("echo2", time())
        return "OK", "succ"
    end
end


return mod












