#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


#include "lworker.h"
#include "lsystem.h"

static void usage (const char *prog) {
    printf("usage: %s main.lua\n", prog);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        usage(argv[0]);
        return EXIT_FAILURE;
    }

    srand(time(0));
    return srv_system_init(argv[1]);
}




