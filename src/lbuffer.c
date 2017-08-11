#include "lsystem.h"





int luaopen_system(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {"wait", NULL},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}



