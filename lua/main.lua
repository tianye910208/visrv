
local src = "lua/init.lua"

print("fork", system.fork(src));
system.wait(200);
print("fork", system.fork(src));
system.wait(200);
print("fork", system.fork(src));
system.wait(200);
print("fork", system.fork(src));
system.wait(200);

while true do
    print("[worker] sys", SRV_WORKER_ID)
    system.wait(1000);
end









