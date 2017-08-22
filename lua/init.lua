package.path = "?;?.lua;lua/?;lua/?.lua"

if WORKER_ID ~= 0 then
    error("[worker]only sys can run init.lua")
end

local sys = "lua/main.lua"
local ids = {}
for i = 1, 3 do
    ids[i] = server.fork(sys);
    server.wait(200);
end

local util = require("util")
util.fork(nil, nil, "test")

dofile(sys)






