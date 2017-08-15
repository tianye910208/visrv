#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


#include "lbuffer.h"

static void usage (const char *progname) {
    printf("usage: %s main.lua\n", progname);
}

static int efunc(lua_State *L) {
    const char *msg = lua_tostring(L, 1);
    if (msg == NULL) { 
        if (luaL_callmeta(L, 1, "__tostring") && lua_type(L, -1) == LUA_TSTRING)
            return 1; 
        else
            msg = lua_pushfstring(L, "(error object is a %s value)", luaL_typename(L, 1));
    }
    luaL_traceback(L, L, msg, 1); 
    return 1;
}

static int pmain(lua_State *L) {
    luaL_checkversion(L);

    int argc = (int)lua_tointeger(L, 1);
    char **argv = (char **)lua_touserdata(L, 2);
    if (argc != 2) {
        usage(argv[0]);
        return 0;
    }

    lua_pushcfunction(L, efunc);

    int status = luaL_loadfile(L, argv[1]);
    if (status == LUA_OK) {
        status = lua_pcall(L, 0, 0, lua_gettop(L)-1);
    }
    if (status == LUA_OK) {
        lua_pushboolean(L, 1); 
    } else {
        printf("[E]%s\n", lua_tostring(L, -1));
        lua_pushboolean(L, 0); 
    }
    return 1;
}

int main(int argc, char **argv) {
    lua_State *L = luaL_newstate(); 
    if (L == NULL) {
        printf("[E]%s %s", argv[0], "create state failed");
        return EXIT_FAILURE;
    }
    luaL_openlibs(L);

    lua_pushcfunction(L, &pmain); 
    lua_pushinteger(L, argc); 
    lua_pushlightuserdata(L, argv);

    int status = lua_pcall(L, 2, 1, 0);
    int result = lua_toboolean(L, -1);
    lua_close(L);

    return (result && status == LUA_OK) ? EXIT_SUCCESS : EXIT_FAILURE;
}

