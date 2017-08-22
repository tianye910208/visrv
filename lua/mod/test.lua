local srv = require("srv")
local printr = srv.printr


local mod = {}

mod.on_init = function(self, src, msg)
    print("[mod]on_init", src, msg)
end

mod.on_exit = function(self, src, msg)
    print("[mod]on_exit", src, msg)

end

mod.on_recv = function(self, src, msg)
    print("[mod]on_data", src, msg)
    printr(data)
end


return mod












