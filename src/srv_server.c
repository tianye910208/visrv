#include <unistd.h>
#include <sys/time.h>
#include "srv_server.h"


static srv_server g_srv;
srv_server*       p_srv = &g_srv;

int srv_server_init(const char* src, int sid) {
    p_srv->sid = sid;
    p_srv->min = 1;
    p_srv->cur = 1;

    memset(p_srv->ptr, 0, SRV_MAX);

    srv_worker* sys = srv_worker_new(0, src, sid);
    if (sys) {
        p_srv->ptr[0] = sys;
        return srv_worker_run(sys);
    } else {
        return EXIT_FAILURE;
    }
}

srv_server* srv_server_info() {
    return p_srv;
}

unsigned int srv_server_time() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    
    unsigned long t = (tv.tv_sec & 0xffffffff) * 1000;
    t += tv.tv_usec / 1000;
    return (unsigned int)t;
}

int srv_server_fork(const char* src) {
    if (p_srv->cur + 8 > SRV_MAX)
        return 0;

    int id_old, id_new;
    do {
        id_old = p_srv->min;
        id_new = id_old;
        do {
            id_new = (id_new + 1) % SRV_MAX;
        } while(id_new == 0 || p_srv->ptr[id_new]);
    } while(!__sync_bool_compare_and_swap(&p_srv->min, id_old, id_new));


    srv_worker* w = srv_worker_new(id_old, src, p_srv->sid);
    if (w) {
        __sync_add_and_fetch(&p_srv->cur, 1);
        __sync_lock_test_and_set(&p_srv->ptr[id_old], w);
        srv_worker_run(w);
        return w->id;
    } else {
        return 0;
    }
}

int srv_server_exit(int wid) {
    __sync_lock_test_and_set(&p_srv->ptr[wid], NULL);
    __sync_sub_and_fetch(&p_srv->cur, 1);

    int id_min_old, id_min_new;
    do {
        id_min_old = p_srv->min;
        id_min_new = wid < id_min_old ? wid : id_min_old;
    } while(!__sync_bool_compare_and_swap(&p_srv->min, id_min_old, id_min_new));

    return 1;
}

srv_worker* srv_server_rand() {
    srv_worker* w = NULL;
    int idx = rand() % p_srv->cur + 1;
    for(int i = 0; p_srv->cur > 1 && idx > 0; i++) {
        w = p_srv->ptr[i % SRV_MAX];
        if (w)
            idx--;
    }
    return w;
}

int srv_server_wait(int msec) {
    usleep(msec*1000);
}

int srv_server_push(int wid, const char* data, int size) {
    srv_worker* w = p_srv->ptr[wid];
    if(w == NULL)
        return 0;

    srv_worker_msg* msg = malloc(sizeof(srv_worker_msg));
    msg->data = data;
    msg->size = size;
    msg->next = NULL;

    return srv_worker_push(w, msg);
}

srv_worker_msg* srv_server_pull(int wid) {
    srv_worker* w = p_srv->ptr[wid];
    if(w == NULL)
        return 0;

    return srv_worker_pull(w);
}




