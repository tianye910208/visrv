#include "lbuffer.h"





int luaopen_buffer(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {"wait", NULL},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}



