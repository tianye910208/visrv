
local log = {}
log.uid = {SERVER_ID, 0, 1}

--log api--
log.i = function(src, ...)
    local arg = {...}
    local str = "[I]"
    for i,v in ipairs(arg) do
        str = str .. tostring(v) .. "\t"
    end
    srv.cast(src, log.uid, str) 
end

log.e = function(src, ...)
    local arg = {...}
    local str = "[E]"
    for i,v in ipairs(arg) do
        str = str .. tostring(v) .. "\t"
    end
    local str = srt.."\n"..traceback()

    srv.cast(src, log.uid, str)
    error(str)
end

--srv mod--
log.on_init = function(self, msg, src, req)
    print("[log]", "init", self.uid[2], self.uid[3])
end

log.on_exit = function(self, msg, src, req)
    print("[log]", "exit")
end

log.on_recv = function(self, msg, src, req)
    --print(msg)
end


return log












