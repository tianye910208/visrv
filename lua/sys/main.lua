print("[server]init", SERVER_ID, WORKER_ID)
package.path = "?;?.lua;lua/?;lua/?.lua"

if WORKER_ID ~= 0 then
    error("[server]only sys can run init.lua")
end

local sys = "lua/sys/sys.lua"
local ids = {}
for i = 1, 3 do
    ids[i] = server.fork(sys);
    server.wait(20);
end

dat = require("sys/dat")
srv = require("sys/srv")

srv.fork(nil, nil, "usr/init")

dofile(sys)






