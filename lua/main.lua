
local src = "lua/init.lua"

local ids = {}
table.insert(ids, system.fork(src));
system.wait(200);
table.insert(ids, system.fork(src));
system.wait(200);
table.insert(ids, system.fork(src));
system.wait(200);
table.insert(ids, system.fork(src));
system.wait(200);

while true do
    local mq = table.pack(system.pull(SRV_WORKER_ID))
    if mq.n > 0 then
        for i,v in ipairs(mq) do
            print(SRV_WORKER_ID, "recv", i, v)
        end
    end

    local idx = system.rand()
    system.push(idx, "Hi"..idx)

    system.wait(1);
end









