// riscv-tangnano9k functions

// Prints a single char to UART
void putchar(const char c);
// Gets a single char from UART
char getchar();
// Prints an integer to the LEDs
void putled(const int x);
// Sleeps 2^n cycles
void sleep(const int n);

// printf stuff

void print_string(const char* s);
int puts(const char* s);
void print_dec(int val);
void print_hex(unsigned int val);
void print_hex_digits(unsigned int val, int nbdigits);
int printf(const char* fmt, ...);