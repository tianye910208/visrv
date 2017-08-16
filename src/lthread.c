#include "lthread.h"


srv_thread* srv_thread_new(int id, const char* src) {
    srv_thread* t = malloc(sizeof(srv_thread));
    t->id = id;
    t->mq = NULL;

    lua_State *L = luaL_newstate(); 
    if (L == NULL) {
        printf("[E][thread]%d %s %s", id, src, "create thread vm failed");
        return NULL;
    }
    luaL_openlibs(L);
    t->vm = L;

    char* str = malloc(strlen(src)+1);
    strcpy(str, src);
    t->src = str;

    pthread_create(&t->tid, NULL, srv_thread_proc, t);   
}

int srv_thread_free(srv_thread* t) {
    if (t->tid) {
        pthread_join(t->tid, NULL);
        t->tid = 0;
    }

    if (t->src) {
        free(t->src);
        t->src = NULL;
    }

    if (t->mq) {
        srv_thread_msg* msg = t->mq;
        t->mq = NULL;
        while(msg) {
            srv_thread_msg *ptr = msg;
            free(ptr);
            msg = msg->next;
        }
    }

    if (t->vm) {
        lua_close(t->vm);
        t->vm = NULL;
    }
}

void* srv_thread_proc(void* ud) {
    srv_thread* t = (srv_thread*)ud;
    if (luaL_loadfile(t->vm, t->src) == LUA_OK) {
        lua_pcall(t->vm, 0, 0, 0);
    }
    return NULL;
}

int srv_thread_push(srv_thread* t, srv_thread_msg* msg) {
    srv_thread_msg* ptr;
    do {
        ptr = t->mq;
        msg->next = ptr;
    } while(!__sync_bool_compare_and_swap(&t->mq, ptr, msg));

}

srv_thread_msg* srv_thread_poll(srv_thread* t) {
    srv_thread_msg* ptr;
    do {
        ptr = t->mq;
    } while(!__sync_bool_compare_and_swap(&t->mq, ptr, NULL));
    return ptr;
}



int luaopen_thread(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
        {NULL, NULL},
    };
    luaL_newlib(L,l);
    return 1;
}



