#include "srv_lualib.h"
#include "srv_server.h"


int luafunc_srv_server_time(lua_State *L) {
    unsigned int t = srv_server_time();
    lua_pushinteger(L, t);
    return 1;
}

int luafunc_srv_server_fork(lua_State *L) {
    const char* src = luaL_checkstring(L, 1);
    int wid = srv_server_fork(src);
    lua_pushinteger(L, wid);
    return 1;
}

int luafunc_srv_server_exit(lua_State *L) {
    int wid = luaL_checkinteger(L, 1);
    int ret = srv_server_exit(wid);
    lua_pushboolean(L, ret);
    return 1;
}

int luafunc_srv_server_rand(lua_State *L) {
    srv_worker* w = srv_server_rand();
    if (w) {
        lua_pushinteger(L, w->id);
        return 1;
    } else {
        return 0;
    }
}

int luafunc_srv_server_list(lua_State *L) {
    srv_server* p = srv_server_info();
    if (p) {
        lua_newtable(L);
        int idx = 0;
        for(int i = 0; i < SRV_MAX && idx < p->cur; i++) {
            srv_worker* w = p->ptr[i];
            if (w) {
                lua_pushinteger(L, w->id);
                lua_rawseti(L, -2, ++idx);
            }
        }
        return 1;
    } else {
        return 0;
    }
}

int luafunc_srv_server_wait(lua_State *L) {
    int msec = luaL_checkinteger(L, 1);
    srv_server_wait(msec);
    return 0;
}

int luafunc_srv_server_push(lua_State *L) {
    int wid = luaL_checkinteger(L, 1);
    size_t size = 0;
    const char* data = luaL_checklstring(L, 2, &size);

    int ret = srv_server_push(wid, data, size);
    lua_pushinteger(L, ret);
    return 1;
}

int luafunc_srv_server_pull(lua_State *L) {
    int wid = luaL_checkinteger(L, 1);
    srv_worker_msg* msg = srv_server_pull(wid);
    if (msg) {
        luaL_checkinteger(L, 1);
        int cnt = 0;

        srv_worker_msg* old = NULL;
        srv_worker_msg* ptr = msg;
        while(ptr) {
            cnt++;
            srv_worker_msg* tmp = ptr->next;
            ptr->next = old;
            old = ptr;
            ptr = tmp;
        }
        luaL_checkstack(L, cnt, "luafunc:srv_server_pull");

        ptr = old;
        while(ptr) {
            lua_pushlstring(L, ptr->data, ptr->size);
            old = ptr;
            ptr = ptr->next;
            free(old);
        }
        return cnt;
    } else {
        return 0;
    }
}

int luaopen_srv_server(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {"time", luafunc_srv_server_time},
        {"fork", luafunc_srv_server_fork},
        {"exit", luafunc_srv_server_exit},
        {"rand", luafunc_srv_server_rand},
        {"list", luafunc_srv_server_list},
        {"wait", luafunc_srv_server_wait},
        {"push", luafunc_srv_server_push},
        {"pull", luafunc_srv_server_pull},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}



int srv_lualib_open(lua_State *L) {
    luaL_checkversion(L);
    luaL_openlibs(L);

    luaL_requiref(L, "server", luaopen_srv_server, 1);

    return 1;
}









