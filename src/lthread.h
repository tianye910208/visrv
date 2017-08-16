#ifndef _L_THREAD_
#define _L_THREAD_

#include <stdlib.h>
#include <string.h>
#include <pthread.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


typedef struct srv_thread_msg
{
    struct srv_thread_msg*  next;
    int                     size;
    const char*             data;
} srv_thread_msg;

typedef struct srv_thread
{
    int             id;
    lua_State*      vm;
    srv_thread_msg* mq;
    char*           src;
    pthread_t       tid;         
} srv_thread;

srv_thread* srv_thread_new(int id, const char* src);
int srv_thread_free(srv_thread* t);

void* srv_thread_proc(void* ud);

int srv_thread_push(srv_thread* t, srv_thread_msg* msg);
srv_thread_msg* srv_thread_poll(srv_thread* t);


int luaopen_thread(lua_State *L);



#endif









