local mod = {}

mod.on_init = function(self, msg, src, req)
    log.i("[mod]on_init", src, msg)
    cast(self.uid, "test")
    fork(nil, "usr/stat", nil, SERVER_ID, WORKER_ID)
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
        for i = 1, 500 do
            fork(nil, "usr/test")
        end
        exit()
    elseif msg == "Hi" then
        log.i("echo1", time())
        wait(1000)
        log.i("echo2", time())
        return "OK", "succ"
    elseif msg == "loop" then
        local i = 1
        while true do
            i = i + 1
        end
    end
end


return mod












