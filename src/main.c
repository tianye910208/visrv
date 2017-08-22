#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


#include "srv_server.h"

static void usage (const char *prog) {
    printf("usage: %s init.lua id\n", prog);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        usage(argv[0]);
        return EXIT_FAILURE;
    }
    int id = argc > 2 ? atoi(argv[2]) : 1;

    srand(time(0));
    return srv_server_init(argv[1], id);
}




