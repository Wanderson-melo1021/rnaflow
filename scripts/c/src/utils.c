#include <stdlib.h>
#include "logger.h"
#include "utils.h"

int check_command(const char *cmd, const char *error_msg) {
    int status = system(cmd);

    if (status != 0) {
        log_message(error_msg);
        return 1;
    }

    return 0;
}

int run_command(const char *cmd, const char *error_msg) {
    int status = system(cmd);

    if (status != 0) {
        log_message(error_msg);
        return 1;
    }

    return 0;
}
