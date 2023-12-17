#include "tang.h"

#include <stdarg.h>
#include <stdbool.h>

// gets a string ending with newline
void gets(char* s) {
    char c;
    int i = 0;

    while (c != '\n') {
        c    = getchar();
        s[i] = c;
        i += 1;
    }
    // char* ch = s;
    // int k;

    // /* until we read a newline */
    // while ((k = getchar()) != '\n') {
    //     /* character is stored at address, and pointer is incremented */
    //     *ch++ = k;
    // }

    // /* add the newline back */
    // *ch = '\n';

    // /* return original pointer */
    // return s;
}

void print_string(const char* s) {
    for (const char* p = s; *p; ++p) {
        putchar(*p);
    }
}

int puts(const char* s) {
    print_string(s);
    putchar('\n');
    return 1;
}

void print_dec(int val) {
    char buffer[255];
    char* p = buffer;
    if (val < 0) {
        putchar('-');
        print_dec(-val);
        return;
    }
    while (val || p == buffer) {
        *(p++) = val % 10;
        val    = val / 10;
    }
    while (p != buffer) {
        putchar('0' + *(--p));
    }
}

void print_hex(unsigned int val) {
    print_hex_digits(val, 8);
}

void print_hex_digits(unsigned int val, int nbdigits) {
    for (int i = (4 * nbdigits) - 4; i >= 0; i -= 4) {
        putchar("0123456789ABCDEF"[(val >> i) % 16]);
    }
}

int printf(const char* fmt, ...) {
    va_list ap;

    for (va_start(ap, fmt); *fmt; fmt++) {
        if (*fmt == '%') {
            fmt++;
            if (*fmt == 's')
                print_string(va_arg(ap, char*));
            else if (*fmt == 'x')
                print_hex(va_arg(ap, int));
            else if (*fmt == 'd')
                print_dec(va_arg(ap, int));
            else if (*fmt == 'c')
                putchar(va_arg(ap, int));
            else
                putchar(*fmt);
        } else
            putchar(*fmt);
    }

    va_end(ap);

    return 0;
}

// char stuff
bool isalpha(char c) {
    return ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'));
}

bool isdigit(char c) {
    return ((c >= '0' && c <= '9'));
}

bool isspace(char c) {
    return (c == ' ');
}

char toupper(char c) {
    return (char)(c - 32);
}

char* strchr(const char* s, int c) {
    const char ch = c;  // cast c to char?
    for (; *s != ch; ++s) {
        if (*s == '\0') {
            return NULL;
        }
    }

    return ((char*)s);
}

// math stuff

int pow(int x, int y) {
    if (y < 0) {
        return 0;
    }

    int c = 1;

    for (int i = 0; i < y; i++) {
        c *= x;
    }

    return c;
}

int abs(int x) {
    if (x < 0)
        return -x;
    return x;
}
