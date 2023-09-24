#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

bool is_prime(uint32_t x);
uint32_t isqrt(uint32_t y);

int main(void) {
    int i = 2;
    while (1) {
        if (is_prime(i))
            printf("%d\n", i);
        i++;
    }
}

bool is_prime(uint32_t x) {
    for (uint32_t i = 2; i <= isqrt(x); i++) {
        // composite
        if (x % i == 0)
            return false;
    }

    return true;
}

// Integer square root (using binary search)
uint32_t isqrt(uint32_t y) {
    uint32_t L = 0;
    uint32_t M;
    uint32_t R = y + 1;

    while (L != R - 1) {
        M = (L + R) / 2;

        if (M * M <= y)
            L = M;
        else
            R = M;
    }

    return L;
}