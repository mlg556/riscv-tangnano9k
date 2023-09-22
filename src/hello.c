void putstring(const char* s);
void sleep(int x);

int main(void) {
    for (;;) {
        putstring("Hello world\n");
        sleep(10000);
    }
    return 0;
}

void sleep(int x) {
    for (int i = 0; i < x; i++) {
    }
}
