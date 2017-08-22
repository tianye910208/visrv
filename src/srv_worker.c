#include "srv_worker.h"
#include "srv_lualib.h"

static int _srv_worker_error(lua_State *L) {
    const char *msg = lua_tostring(L, 1);
    if (msg == NULL) { 
        if (luaL_callmeta(L, 1, "__tostring") && lua_type(L, -1) == LUA_TSTRING)
            return 1; 
        else
            msg = lua_pushfstring(L, "(error object is a %s value)", luaL_typename(L, 1));
    }
    luaL_traceback(L, L, msg, 1); 
    return 1;
}

static int _srv_worker_pmain(lua_State *L) {
    luaL_checkversion(L);

    srv_worker* w = (srv_worker*)lua_touserdata(L, 1);


    lua_pushinteger(L, w->id);
    lua_setglobal(L, "WORKER_ID");

    lua_pushcfunction(L, _srv_worker_error);

    int status = luaL_loadfile(L, w->src);
    if (status == LUA_OK) {
        status = lua_pcall(L, 0, 0, 2);
    }
    if (status == LUA_OK) {
        lua_pushboolean(L, 1); 
    } else {
        printf("[E][worker]%d %s\n", w->id, lua_tostring(L, -1));
        lua_pushboolean(L, 0); 
    }
    return 1;
}

srv_worker* srv_worker_new(int id, const char* src) {
    srv_worker* w = malloc(sizeof(srv_worker));
    w->id = id;
    w->mq = NULL;
    w->tid = 0;
    w->ret = -1;

    lua_State *L = luaL_newstate(); 
    if (L == NULL) {
        printf("[E][worker]%d %s %s\n", id, src, "create vm failed");
        return NULL;
    }
    srv_lualib_open(L);
    w->vm = L;

    w->src = malloc(strlen(src)+1);
    strcpy(w->src, src);

    return w;
}

int srv_worker_run(srv_worker* w) {
    if (w->id == 0)
        srv_worker_proc(w);
    else
        pthread_create(&w->tid, NULL, srv_worker_proc, w);   
    return w->ret;
}

int srv_worker_free(srv_worker* w) {
    if (w->tid) {
        pthread_join(w->tid, NULL);
        w->tid = 0;
    }

    if (w->src) {
        free(w->src);
        w->src = NULL;
    }

    if (w->mq) {
        srv_worker_msg* msg = w->mq;
        w->mq = NULL;
        while(msg) {
            srv_worker_msg *ptr = msg;
            free(ptr);
            msg = msg->next;
        }
    }

    if (w->vm) {
        lua_close(w->vm);
        w->vm = NULL;
    }
}




void* srv_worker_proc(void* ud) {
    srv_worker* w = (srv_worker*)ud;
    lua_State* L = w->vm;
 
    lua_pushcfunction(L, &_srv_worker_pmain); 
    lua_pushlightuserdata(L, w);

    int status = lua_pcall(L, 1, 1, 0);
    int result = lua_toboolean(L, -1);

    w->ret = (result && status == LUA_OK) ? EXIT_SUCCESS : EXIT_FAILURE;
    return NULL;
}

int srv_worker_push(srv_worker* w, srv_worker_msg* msg) {
    srv_worker_msg* ptr;
    do {
        ptr = w->mq;
        msg->next = ptr;
    } while(!__sync_bool_compare_and_swap(&w->mq, ptr, msg));

    return 1;
}

srv_worker_msg* srv_worker_pull(srv_worker* w) {
    srv_worker_msg* ptr;
    do {
        ptr = w->mq;
    } while(!__sync_bool_compare_and_swap(&w->mq, ptr, NULL));

    return ptr;
}





