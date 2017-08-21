#include "srv_lualib.h"
#include "srv_system.h"



int luafunc_srv_system_fork(lua_State *L) {
    const char* src = luaL_checkstring(L, 1);
    int wid = srv_system_fork(src);
    lua_pushinteger(L, wid);
    return 1;
}

int luafunc_srv_system_exit(lua_State *L) {
    int wid = luaL_checkinteger(L, 1);
    int ret = srv_system_exit(wid);
    lua_pushboolean(L, ret);
    return 1;
}

int luafunc_srv_system_rand(lua_State *L) {
    srv_worker* w = srv_system_rand();
    if (w) {
        lua_pushinteger(L, w->id);
        return 1;
    } else {
        return 0;
    }
}

int luafunc_srv_system_wait(lua_State *L) {
    int msec = luaL_checkinteger(L, 1);
    srv_system_wait(msec);
    return 0;
}

int luafunc_srv_system_push(lua_State *L) {
    int wid = luaL_checkinteger(L, 1);
    const char* str = luaL_checkstring(L, 2);

    int ret = srv_system_push(wid, str);
    lua_pushinteger(L, ret);
    return 1;
}

int luafunc_srv_system_pull(lua_State *L) {
    int wid = luaL_checkinteger(L, 1);
    srv_worker_msg* msg = srv_system_pull(wid);
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
        luaL_checkstack(L, cnt, "luafunc:srv_system_pull");

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

int luaopen_srv_system(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {"fork", luafunc_srv_system_fork},
        {"exit", luafunc_srv_system_exit},
        {"rand", luafunc_srv_system_rand},
        {"wait", luafunc_srv_system_wait},
        {"push", luafunc_srv_system_push},
        {"pull", luafunc_srv_system_pull},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}



int srv_lualib_open(lua_State *L) {
    luaL_checkversion(L);
    luaL_openlibs(L);

    luaL_requiref(L, "system", luaopen_srv_system, 1);

    return 1;
}









