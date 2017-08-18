#ifndef _SRV_WORKER_
#define _SRV_WORKER_

#include <stdlib.h>
#include <string.h>
#include <pthread.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


typedef struct srv_worker_msg
{
    struct srv_worker_msg*  next;
    int                     size;
    const char*             data;
} srv_worker_msg;

typedef struct srv_worker
{
    int             id;
    lua_State*      vm;
    srv_worker_msg* mq;
    char*           src;
    pthread_t       tid;         
    int             ret;
} srv_worker;

srv_worker* srv_worker_new(int id, const char* src);
int srv_worker_run(srv_worker* w);
int srv_worker_free(srv_worker* w);

void* srv_worker_proc(void* ud);

int srv_worker_push(srv_worker* w, srv_worker_msg* msg);
srv_worker_msg* srv_worker_pull(srv_worker* w);


#endif









