#include "srv_socket.h"





int luaopen_socket(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {NULL, NULL},
    };
    luaL_newlib(L,l);
    return 1;
}



