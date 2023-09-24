#include "tang.h"

char c;

int main(void) {
    for (;;) {
        c = getchar();
        printf("%c\n", c);
    }
}