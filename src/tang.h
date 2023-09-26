// riscv-tangnano9k functions

#include <stdbool.h>
#include <stddef.h>

// errno stuff??

#define EINVAL 22
#define ERANGE 34

// Prints a single char to UART
void putchar(const char c);
// Gets a single char from UART
char getchar();
// Prints an integer to the LEDs
void putled(const int x);
// Sleeps 2^n cycles
void sleep(const int n);

// printf stuff

void print_string(const char *s);
int puts(const char *s);
void print_dec(int val);
void print_hex(unsigned int val);
void print_hex_digits(unsigned int val, int nbdigits);
int printf(const char *fmt, ...);

// get string, blocking
char *gets(char *s);

// char stuff
bool isalpha(char c);
bool isdigit(char c);
bool isspace(char c);
char toupper(char c);
char *strchr(const char *s, int c);

void *memset(void *s, int c, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
char *strcpy(char *dest, const char *src);
char *strncpy(char *dest, const char *src, size_t n);
int strcmp(const char *p1, const char *p2);
size_t strlen(const char *p);
extern int rand();

// some math stuff
int pow(int x, int y);
int abs(int x);
