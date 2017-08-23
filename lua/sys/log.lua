
local mod = {}
mod.uid = {SERVER_ID, 0, 1}

--log api--
mod.i = function(...)
    local arg = {...}
    local str = "[I]"
    for i,v in ipairs(arg) do
        str = str .. tostring(v) .. "\t"
    end
    srv.send(src, nil, mod.uid, str) 
end

mod.e = function(...)
    local arg = {...}
    local str = "[E]"
    for i,v in ipairs(arg) do
        str = str .. tostring(v) .. "\t"
    end
    local str = srt.."\n"..debug.traceback()

    srv.send(src, nil, mod.uid, str)
    error(str)
end

--srv mod--
mod.on_init = function(self, msg, src, req)
    print("[log]", "init", self.uid[2], self.uid[3])
end

mod.on_exit = function(self, msg, src, req)
    print("[log]", "exit")
end

mod.on_recv = function(self, msg, src, req)
    print(msg)
end


return mod












