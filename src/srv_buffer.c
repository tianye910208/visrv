#include "stdlib.h"
#include "string.h"

#include "srv_buffer.h"

#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

#define BUF_SIZE 512

srv_buffer* srv_buffer_new() {
    srv_buffer* buf = (srv_buffer*)malloc(sizeof(srv_buffer));
    buf->next = NULL;
    buf->size = 0;
    buf->maxn = BUF_SIZE;
    buf->data = (char*)malloc(buf->maxn);

    return buf;
}

int srv_buffer_free(srv_buffer* buf) {
    if (buf) {
        if(buf->data) {
            free(buf->data);
            buf->data = NULL;
        }
        free(buf);
        return 1;
    }
    return 0;
}


int srv_buffer_size(srv_buffer* buf) {
    int size = 0;
    while (buf->size == -1) {
        size += buf->maxn;
        buf = buf->next;
    }
    size += buf->size;
    return size;
}

srv_buffer* srv_buffer_next(srv_buffer* buf) {
    while (buf->size == -1) {
        buf = buf->next;
    }
    return buf->next;
}

int srv_buffer_read(srv_buffer* buf, int pos, char* out, int len) {
    while (pos > buf->maxn) {
        pos -= buf->maxn;
        buf = buf->next;
    }

    if (buf) {
        if(pos + len <= buf->size) {
            memcpy(out, buf->data+pos, len);
            return len;
        } else {
            char* ptr = out;
            int size = 0;
            while(buf->size == -1 && len > 0) {
                int add = MIN(buf->maxn - pos, len);
                memcpy(ptr, buf->data+pos, add);
                pos = 0;
                ptr += add;
                len -= add;
                buf = buf->next;
            }
            if(len > 0) {
                int add = MIN(buf->size, len);
                memcpy(ptr, buf->data+pos, add);
                ptr += add;
            }
            return ptr - out;
        }
    } else {
        return 0;
    }
}

int srv_buffer_write(srv_buffer* buf, int pos, const char* inb, int len)
{
    if (pos + len <= buf->maxn) {
        memcpy(buf->data+pos, inb, len);
        buf->size = pos + len;
        return len;
    }
 
    const char* ptr = inb;
    int add = buf->maxn - pos;
    memcpy(buf->data+pos, ptr, add);
    ptr += add;
    len -= add;

    while(len > 0) {
        buf->size = -1;
        buf->next = srv_buffer_new();
        buf = buf->next;

        int add = MIN(buf->maxn, len);
        memcpy(buf->data, ptr, add);
        ptr += add;
        len -= add;
        buf->size = add;
    }
    return ptr - inb;
}



int luaopen_buffer(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {"wait", NULL},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    return 1;
}



