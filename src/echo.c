#include "tang.h"

char c;

int main(void) {
    for (;;) {
        c = getchar();
        // to upper case
        c -= 32;
        printf("%c", c);
    }
}