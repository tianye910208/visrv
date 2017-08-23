
local mod = {}

local worker_mq1 = {}
local worker_mq2 = {}

mod.push = function(cmd)
    table.insert(worker_mq1, cmd)
end

mod.pull = function()
    if next(worker_mq1) then
        worker_mq1, worker_mq2 = worker_mq2, worker_mq1
        return worker_mq2
    end
    return nil 
end

mod.fork = function(src, req, cls, arg, sid, wid, mid)
    local msg = {"fork", cls, arg, mid}
    mod.send(src, req, {sid or SERVER_ID, wid or 255, 0}, msg)
end

mod.exit = function(src, req, uid, arg)
    local sid, wid, mid = uid[1], uid[2], uid[3]
    local msg = {"exit", mid, arg}
    mod.send(src, req, {sid, wid, 0}, msg)
end

mod.send = function(src, req, uid, msg)
    local sid, wid, mid = uid[1], uid[2], uid[3]
    local cmd = {
        mid = mid,
        src = src,
        req = req,
        msg = msg,
    }

    if sid ~= SERVER_ID then
        mod.push({
            mid = 0,
            msg = {"send", sid, wid, cmd},
        })
    elseif wid == WORKER_ID then
        mod.push(cmd)
    else
        if wid == 255 then
            wid = server.rand()
        end
        server.push(wid, dat.encode(cmd))
    end
end


return mod




