#ifndef _SRV_SERVER_
#define _SRV_SERVER_

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "srv_worker.h"


#define SRV_MAX 255

typedef struct srv_server
{
    int         sid;
    int         min;
    int         cur;
    srv_worker* ptr[SRV_MAX];
} srv_server;


int srv_server_init(const char* src, int sid);
float srv_server_time();
srv_server* srv_server_info();

int srv_server_fork(const char* src);
int srv_server_exit(int wid);

srv_worker* srv_server_rand();
int srv_server_wait(int msec);

int srv_server_push(int wid, const char* data, int size);
srv_worker_msg* srv_server_pull(int wid);


#endif









