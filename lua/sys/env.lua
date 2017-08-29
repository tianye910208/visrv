local srv = srv
local dat = dat
local log = log

local env = {}

env._load_hash = {}
env._load_func = function(name)
    local f = env._load_hash[name]
    if f then
        return f
    end
    local filename, err = package.searchpath(name, package.path)
    if filename == nil then
        error(err)
    end
    local f,err = loadfile(filename)
    if f == nil then
        error(err)
    end
    env._load_hash[name] = f
    return f
end

env._create_env = function()
    local e = {}
    e._G = e
    e._ENV = e

    e.SERVER_ID = SERVER_ID
    e.WORKER_ID = WORKER_ID

    e.load = load
    e.next = next
    e.type = type 
    e.print = print
    e.pairs = pairs
    e.ipairs = ipairs
    e.select = select
    e.rawget = rawget
    e.rawset = rawset
    e.rawlen = rawlen
    e.rawequal = rawequal
    e.tonumber = tonumber
    e.tostring = tostring
    e.getmetatable = getmetatable
    e.setmetatable = setmetatable
    e.collectgarbage = collectgarbage

    e.os = os
    e.io = io
    e.utf8 = utf8
    e.math = math
    e.debug = debug
    e.table = table
    e.string = string

    e.require = function(name) return env.require_src(name, e) end
    return e
end

env._create_api = function(e, m)
    e.req = srv.req
    e.ret = srv.ret
    e.send = srv.send
    e.fork = function(...) return srv.fork(m.uid, ...) end
    e.exit = function(...) return srv.exit(m.uid, ...) end
    e.cast = function(uid, msg, msec) srv.cast(m.uid, uid, msg, msec) end
    e.call = function(uid, msg) return srv.call(m.uid, uid, msg) end
    e.wait = function(msec) return srv.wait(m.uid, msec) end
    e.time = function() return srv.time end

    e.dat = dat
    e.log = {}
    e.log.i = function(...) log.i(m.uid, ...) end
    e.log.e = function(...) log.e(m.uid, ...) end

    return e
end


env.require_src = function(name, e)
    local f = env._load_func(name)
    debug.setupvalue(f, 1, e)
    return f()
end

env.require_mod = function(name)
    local f = env._load_func(name)
    local e = env._create_env()
    debug.setupvalue(f, 1, e)
    local m = f()
    m._ENV = e
    e._MOD = m
    env._create_api(e, m)
    return m
end

return env


















