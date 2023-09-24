#include "tang.h"

#define N 19

int main(void) {
    for (;;) {
        putled(21);
        printf("hello\n");
        sleep(N);
        putled(42);
        printf("there\n");
        sleep(N);
    }
    return 0;
}