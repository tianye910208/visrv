print("[server]init", SERVER_ID, WORKER_ID)
package.path = "?;?.lua;lua/?;lua/?.lua"

if WORKER_ID ~= 0 then
    error("[server]only sys can run init.lua")
end

local sys = "lua/main.lua"
local ids = {}
for i = 1, 3 do
    ids[i] = server.fork(sys);
    server.wait(20);
end

local srv = require("srv")
srv.fork(nil, nil, "mod/test")

dofile(sys)






