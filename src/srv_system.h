#ifndef _SRV_SYSTEM_
#define _SRV_SYSTEM_

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "srv_worker.h"


#define SRV_MAX 255

typedef struct srv_system
{
    int         min;
    int         cur;
    srv_worker* ptr[SRV_MAX];
} srv_system;


int srv_system_init(const char* src);

int srv_system_fork(const char* src);
int srv_system_exit(int wid);

srv_worker* srv_system_rand();
int srv_system_wait(int msec);

int srv_system_push(int wid, const char* str);
srv_worker_msg* srv_system_pull(int wid);


#endif









