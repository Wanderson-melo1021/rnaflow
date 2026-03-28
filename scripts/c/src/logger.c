#include <stdio.h>
#include <time.h>
#include "logger.h"

void log_message(const char *message) {
    time_t now = time(NULL);
    struct tm *t = localtime(&now);

    if (t == NULL) {
        fprintf(stderr, "[unknown-time] %s\n", message);
        return;
    }

    printf("[%04d-%02d-%02d %02d:%02d:%02d] %s\n",
            t->tm_year + 1900,
            t->tm_mon + 1,
            t->tm_mday,
            t->tm_hour,
            t->tm_min,
            t->tm_sec,
            message);
}

