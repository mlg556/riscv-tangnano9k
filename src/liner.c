#include "tang.h"

#define MAX_LINE 99

char line[MAX_LINE];

void getline(char* s) {
    char c;
    int i = 0;

    while (true) {
        c = getchar();
        if (c == '\n')
            break;
        s[i] = c;
        i += 1;
        sleep(5);
    }
};

void clearline(char* s) {
    for (int i = 0; i < MAX_LINE; i++) {
        s[i] = 0;
    }
}

int main(void) {
    for (;;) {
        getline(line);
        printf("%s", line);
        clearline(line);
    }
}