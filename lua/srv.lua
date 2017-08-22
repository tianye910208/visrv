
local mod = {}

mod.encode = function(var)
    local str = {}
    local str_map = {}
    local tbl = {} --{{{tag, key,tag,val}},...}
    local tbl_map = {}

    local function _encode_var(v)
        local t = type(v)
        if t == "number" then
            if math.tointeger(v) then
                return '\1', string.pack("<i4", v)
            else
                return '\2', string.pack("<f",v)
            end
        elseif t == "boolean" then
            if v then
                return '\3', "\1"
            else
                return '\3', "\0"
            end
        elseif t == "string" then
            local idx = str_map[v]
            if not idx then
                idx = #str + 1
                str[idx] = v
                str_map[v] = idx
            end
            return '\4', string.pack("<I4", idx)
        elseif t == "table" then
            local idx = tbl_map[v]
            if not idx then
                local t = {}
                idx = #tbl + 1
                tbl[idx] = t
                tbl_map[t] = idx

                for k,v in pairs(v) do
                    local k1,k2 = _encode_var(k)
                    local v1,v2 = _encode_var(v)
                    table.insert(t, {k1, k2, v1, v2})
                end
            end
            return '\5', string.pack("<I4", idx)
        else
            error("Unsupport value " .. tostring(v))
        end
    end
    local tag, val = _encode_var(var)

    local bin = {}
    table.insert(bin, string.pack("<I4", #str))
    for i,v in ipairs(str) do
        table.insert(bin, string.pack("<I2", string.len(v)))
        table.insert(bin, v)
    end

    table.insert(bin, string.pack("<I4", #tbl))
    for i,t in ipairs(tbl) do
        table.insert(bin, string.pack("<I2", #t))
        for j,v in ipairs(t) do
            table.insert(bin, v[1])
            table.insert(bin, v[2])
            table.insert(bin, v[3])
            table.insert(bin, v[4])
        end
    end

    table.insert(bin, tag)
    table.insert(bin, val)
 
    return table.concat(bin)
end

mod.decode = function(bin)
    local str = {}
    local tbl = {}

    local cnt, pos = string.unpack("<I4", bin) 
    for i = 1, cnt do
        local len = string.unpack("<I2", bin, pos) 
        pos = pos + 2
        str[i] = string.sub(bin, pos, pos + len - 1)
        pos = pos + len
    end


    local function _decode_var(bin, pos)
        local tag = string.unpack("<B", bin, pos) 
        pos = pos + 1
        if tag == 1 then
            return (string.unpack("<i4", bin, pos)), pos + 4
        elseif tag == 2 then
            return (string.unpack("<f", bin, pos)), pos + 4 
        elseif tag == 3 then
            return (string.unpack("<B", bin, pos)), pos + 1 
        elseif tag == 4 then
            return str[string.unpack("<I4", bin, pos)], pos + 4
        elseif tag == 5 then
            return tbl[string.unpack("<I4", bin, pos)], pos + 4
        else
            error("Unsupport types " .. tostring(tag))
        end
    end

    local cnt= string.unpack("<I4", bin, pos) 
    pos = pos + 4
    for i = 1, cnt do
        local t = {}
        tbl[i] = t
    end
    for i,t in ipairs(tbl) do
        local n= string.unpack("<I2", bin, pos) 
        pos = pos + 2
        for j = 1, n do
            local key, val
            key, pos = _decode_var(bin, pos)
            val, pos = _decode_var(bin, pos)
            t[key] = val
        end
    end

    local val, pos = _decode_var(bin, pos)
    return val
end

local function _printr(var, tab)
    local t = type(var)
    if t == "table" then
        local ss = "{\n"
        for k,v in pairs(var) do
            ss = ss .. tab.."    "..k.." = "
            ss = ss .. _printr(v, tab.."    ")..",\n"
        end
        ss = ss..tab.."}"
        return ss
    elseif t == "string" then
        return "\""..var.."\""
    else
        return tostring(var)
    end
end

mod.printr = function(v) 
    print(_printr(v, "")) 
end

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
    msg = {"fork", cls, arg, mid}
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
        mod = mid,
        src = src,
        req = req,
        msg = msg,
    }

    if sid ~= SERVER_ID then
        mod.push({
            mod = 0,
            msg = {"send", sid, wid, cmd},
        })
    elseif wid == WORKER_ID then
        mod.push(cmd)
    else
        if wid == 255 then
            wid = server.rand()
        end
        server.push(wid, mod.encode(cmd))
    end
end



return mod




