#ifndef _L_THREAD_
#define _L_THREAD_

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


typedef struct srv_thread
{
    int         id;
    lua_State*  vm;

    srv_buffer* qa;
    srv_buffer* qb;
} srv_thread;

srv_thread* srv_thread_new(int id, const char* src);
int srv_thread_free(srv_thread* t);

int srv_thread_push(srv_thread* t, srv_buffer* buf);
srv_buffer* srv_thread_poll(srv_thread* t);


int luaopen_thread(lua_State *L);



#endif









