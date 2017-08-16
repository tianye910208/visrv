#ifndef _L_SYSTEM_
#define _L_SYSTEM_

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "lworker.h"


#define SRV_MAX 256

typedef struct srv_system
{
    int         min;
    int         cur;
    srv_worker* ptr[SRV_MAX];
} srv_system;


int srv_system_init(const char* src);
int srv_system_fork(const char* src);
int srv_system_exit(int tid);

srv_worker* srv_system_rand();
int srv_system_wait(int msec);
int srv_system_push(int tid, const char* msg);
srv_worker_msg* srv_system_poll(int tid);


int luaopen_system(lua_State *L);


#endif









