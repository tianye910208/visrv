local t_insert = table.insert
local t_concat = table.concat
local str_len = string.len
local str_sub = string.sub
local str_byte = string.byte
local str_pack = string.pack
local str_unpack = string.unpack
local str_format = string.format


local dat = {}

dat.encode = function(var)
    local str = {}
    local str_map = {}
    local tbl = {} --{{{tag, key,tag,val}},...}
    local tbl_map = {}

    local function _encode_var(v)
        local t = type(v)
        if t == "number" then
            if math.tointeger(v) then
                return '\1', str_pack("<i4", v)
            else
                return '\2', str_pack("<f",v)
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
            return '\4', str_pack("<I4", idx)
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
                    t_insert(t, {k1, k2, v1, v2})
                end
            end
            return '\5', str_pack("<I4", idx)
        else
            error("Unsupport value " .. tostring(v))
        end
    end
    local tag, val = _encode_var(var)

    local bin = {}
    t_insert(bin, str_pack("<I4", #str))
    for i,v in ipairs(str) do
        t_insert(bin, str_pack("<I2", str_len(v)))
        t_insert(bin, v)
    end

    t_insert(bin, str_pack("<I4", #tbl))
    for i,t in ipairs(tbl) do
        t_insert(bin, str_pack("<I2", #t))
        for j,v in ipairs(t) do
            t_insert(bin, v[1])
            t_insert(bin, v[2])
            t_insert(bin, v[3])
            t_insert(bin, v[4])
        end
    end

    t_insert(bin, tag)
    t_insert(bin, val)
 
    return t_concat(bin)
end

dat.decode = function(bin)
    local str = {}
    local tbl = {}

    local cnt, pos = str_unpack("<I4", bin) 
    for i = 1, cnt do
        local len = str_unpack("<I2", bin, pos) 
        pos = pos + 2
        str[i] = str_sub(bin, pos, pos + len - 1)
        pos = pos + len
    end


    local function _decode_var(bin, pos)
        local tag = str_unpack("<B", bin, pos) 
        pos = pos + 1
        if tag == 1 then
            return (str_unpack("<i4", bin, pos)), pos + 4
        elseif tag == 2 then
            return (str_unpack("<f", bin, pos)), pos + 4 
        elseif tag == 3 then
            return (str_unpack("<B", bin, pos)), pos + 1 
        elseif tag == 4 then
            return str[str_unpack("<I4", bin, pos)], pos + 4
        elseif tag == 5 then
            return tbl[str_unpack("<I4", bin, pos)], pos + 4
        else
            error("Unsupport types " .. tostring(tag))
        end
    end

    local cnt= str_unpack("<I4", bin, pos) 
    pos = pos + 4
    for i = 1, cnt do
        local t = {}
        tbl[i] = t
    end
    for i,t in ipairs(tbl) do
        local n= str_unpack("<I2", bin, pos) 
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

dat.tostr = function(v)
    return _printr(v, "")
end

dat.tohex = function(bin)
    local str = ""
    for i = 1, str_len(bin) do
        str = str .. str_format("%02X ", str_byte(bin,i))
        if i % 4 == 0 then
            str = str .. " "
            if i % 16 == 0 then
                str = str .. "\n"
            end
        end
    end
    return str
end

return dat




