#include "lthread.h"





int luaopen_thread(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {NULL, NULL},
    };
    luaL_newlib(L,l);
    return 1;
}



