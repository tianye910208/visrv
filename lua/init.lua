

while true do
    local mq = table.pack(system.pull(SRV_WORKER_ID))
    if mq.n > 0 then
        for i,v in ipairs(mq) do
            print(SRV_WORKER_ID, "recv", v)
            system.push(0, "Echo"..v)
        end
    end

    system.wait(1);
end






