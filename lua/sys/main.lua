print("[server]init", SERVER_ID, WORKER_ID)
package.path = "?;?.lua;lua/?;lua/?.lua"

if WORKER_ID ~= 0 then
    error("[server]only sys can run init.lua")
end

local sys = "lua/sys/sys.lua"
for i = 1, 3 do
    server.fork(sys);
end

dofile(sys)






