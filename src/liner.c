#include "tang.h"

#define MAX_LINE 99

char line[MAX_LINE];

void clearline(char* s) {
    for (int i = 0; i < MAX_LINE; i++) {
        s[i] = 0;
    }
}

int main(void) {
    for (;;) {
        gets(line);
        printf("%s", line);
        clearline(line);
    }
}