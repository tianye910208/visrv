#ifndef _L_SYSTEM_
#define _L_SYSTEM_

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "lthread.h"
#include "lbuffer.h"

typedef struct srv_system
{
    int         tid_min;
    int         tid_max;
    srv_thread* tid_map[256];
} srv_system;


int srv_system_init(srv_system* sys);
int srv_system_free(srv_system* sys);

int srv_system_exit(srv_system* sys);
int srv_system_push(srv_system* sys, int tid, srv_buffer* buf);
int srv_system_wait(int msec);


int luaopen_system(lua_State *L);



#endif









