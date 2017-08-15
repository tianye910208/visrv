#ifndef _L_BUFFER_
#define _L_BUFFER_

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


typedef struct srv_buffer
{
    char* data;
    int   maxn;
    int   size;

    struct srv_buffer* next;
} srv_buffer;

srv_buffer* srv_buffer_new();
int srv_buffer_free(srv_buffer* buf);


int srv_buffer_size(srv_buffer* buf);
srv_buffer* srv_buffer_next(srv_buffer* buf);

int srv_buffer_read(srv_buffer* buf, int pos, char* out, int len);
int srv_buffer_write(srv_buffer* buf, int pos, const char* inb, int len);

int srv_buffer_pack(srv_buffer* buf, lua_State* L, int idx);
int srv_buffer_unpack(srv_buffer* buf, lua_State* L);


int luaopen_buffer(lua_State *L);



#endif









