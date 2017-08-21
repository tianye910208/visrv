#include <unistd.h>
#include "srv_system.h"


static srv_system g_sys;
srv_system*       p_sys = &g_sys;

int srv_system_init(const char* src) {
    p_sys->min = 1;
    p_sys->cur = 1;

    memset(p_sys->ptr, 0, SRV_MAX);

    srv_worker* sys = srv_worker_new(0, src);
    if (sys) {
        p_sys->ptr[0] = sys;
        return srv_worker_run(sys);
    } else {
        return EXIT_FAILURE;
    }
}

int srv_system_fork(const char* src) {
    if (p_sys->cur + 8 > SRV_MAX)
        return 0;

    int id_old, id_new;
    do {
        id_old = p_sys->min;
        id_new = id_old;
        do {
            id_new = (id_new + 1) % SRV_MAX;
        } while(id_new == 0 || p_sys->ptr[id_new]);
    } while(!__sync_bool_compare_and_swap(&p_sys->min, id_old, id_new));


    srv_worker* w = srv_worker_new(id_old, src);
    if (w) {
        __sync_add_and_fetch(&p_sys->cur, 1);
        __sync_lock_test_and_set(&p_sys->ptr[id_old], w);
        srv_worker_run(w);
        return w->id;
    } else {
        return 0;
    }
}

int srv_system_exit(int wid) {
    __sync_lock_test_and_set(&p_sys->ptr[wid], NULL);
    __sync_sub_and_fetch(&p_sys->cur, 1);

    int id_min_old, id_min_new;
    do {
        id_min_old = p_sys->min;
        id_min_new = wid < id_min_old ? wid : id_min_old;
    } while(!__sync_bool_compare_and_swap(&p_sys->min, id_min_old, id_min_new));

    return 1;
}

srv_worker* srv_system_rand() {
    srv_worker* w = NULL;
    int idx = rand() % (p_sys->cur - 1) + 1;
    int i = 1;
    for(int i = 1; p_sys->cur > 1 && idx > 0; i++) {
        w = p_sys->ptr[i % SRV_MAX];
        if (w && w->id > 0)
            idx--;
    }
    return w;
}

int srv_system_wait(int msec) {
    usleep(msec*1000);
}

int srv_system_push(int wid, const char* str) {
    srv_worker* w = p_sys->ptr[wid];
    if(w == NULL)
        return 0;

    srv_worker_msg* msg = malloc(sizeof(srv_worker_msg));
    msg->data = str;
    msg->size = strlen(str);
    msg->next = NULL;

    return srv_worker_push(w, msg);
}

srv_worker_msg* srv_system_pull(int wid) {
    srv_worker* w = p_sys->ptr[wid];
    if(w == NULL)
        return 0;

    return srv_worker_pull(w);
}




