static volatile unsigned char* uart_txr = (volatile unsigned char*)0x20000000;
static volatile unsigned char* uart_ctr = (volatile unsigned char*)0x20000008;

static void uart_tx(char c)
{
    *uart_txr = (unsigned char)c;
}

void uart_print(const char* s)
{
    for (int i = 0; s[i] != '\0'; i++) {
        uart_tx(s[i]);
    }
} 

void uart_init()
{
    *uart_ctr = 1;
}

int main()
{
    uart_init();
    uart_print("hello riscv!\n");
    return 0;
}