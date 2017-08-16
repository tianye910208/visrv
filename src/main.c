#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


#include "lworker.h"

static void usage (const char *progname) {
    printf("usage: %s main.lua\n", progname);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        usage(argv[0]);
        return EXIT_FAILURE;
    }

    srv_worker* w = srv_worker_new(0, argv[1]); 
    int ret = w->ret;
    srv_worker_free(w);
    return ret;
}

