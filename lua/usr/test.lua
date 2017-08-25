local mod = {}

mod.on_init = function(self, msg, src, req)
    log.i("[mod]on_init", src, msg)
    cast(self.uid, "test", 1000)
end

mod.on_exit = function(self, msg, src, req)
    log.i("[mod]on_exit", src, msg)

end

mod.on_recv = function(self, msg, src, req)
    log.i("[mod]["..time().."]on_data", src, msg)
    if msg == "test" then
        cast(self.uid, "test", 1000)
    end
end


return mod












