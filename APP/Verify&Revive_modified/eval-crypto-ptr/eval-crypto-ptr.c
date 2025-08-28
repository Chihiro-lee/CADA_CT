#include <RAhook.h>
typedef unsigned int uint16_t;

/************************ UART INIT CODE *************************/

#define BAUD 57600
#define MCLK_FREQ 1000000UL // 1 MHz DCO
#define BRDIV ((MCLK_FREQ / BAUD) / 16)
#define MOD ((MCLK_FREQ / BAUD) % 16)

void uart_init(void) {
    // 配置 DCO 为 1 MHz
    UCSCTL4 = SELA__REFOCLK | SELS__DCOCLKDIV | SELM__DCOCLKDIV;
    UCSCTL0 = 0; // 设置最低 DCOx, MODx
    UCSCTL1 = DCORSEL_2; // 选择 DCO 范围
    UCSCTL2 = FLLD_0 | ((MCLK_FREQ / 32768) - 1); // FLL 设置为 1 MHz
    __delay_cycles(1000); // 等待 DCO 稳定

    // 配置 USCI_A1 为 UART
    P4SEL |= BIT4 | BIT5; // P4.4 = TXD, P4.5 = RXD
    UCA1CTL1 |= UCSWRST; // 保持 USCI 重置
    UCA1CTL1 |= UCSSEL_2; // 使用 SMCLK
    UCA1BR0 = BRDIV & 0xFF;
    UCA1BR1 = (BRDIV >> 8) & 0xFF;
    UCA1MCTL = (MOD << 4) | UCOS16; // 调制和过采样
    UCA1CTL0 = 0; // 8 位，无奇偶校验，1 停止位
    UCA1CTL1 &= ~UCSWRST; // 解除 USCI 重置
    UCA1IE |= UCRXIE | UCTXIE; // 启用 RX 和 TX 中断
}

void uart_putchar(char c) {
    if (c == '\n') {
        uart_putchar('\r');
    }
    while (!(UCA1IFG & UCTXIFG)); // 等待 TX 缓冲区就绪
    UCA1TXBUF = c; // 发送字符
}

void uart_puts(char *c) {
    while (*c) {
        uart_putchar(*c++);
    }
}

/**************** SPECK CRYPTO ********************/

#define SPECK_TYPE uint16_t
#define SPECK_ROUNDS 22
#define SPECK_KEY_LEN 4

#define ROR(x, r) ((x >> r) | (x << ((sizeof(SPECK_TYPE) * 8) - r)))
#define ROL(x, r) ((x << r) | (x >> ((sizeof(SPECK_TYPE) * 8) - r)))

#define R(x, y, k) (x = ROR(x, 7), x += y, x ^= k, y = ROL(y, 2), y ^= x)
#define RR(x, y, k) (y ^= x, y = ROR(y, 2), x ^= k, x -= y, x = ROL(x, 7))

void speck_expand(SPECK_TYPE const K[static SPECK_KEY_LEN], SPECK_TYPE S[static SPECK_ROUNDS])
{
    SPECK_TYPE i, b = K[0];
    SPECK_TYPE a[SPECK_KEY_LEN - 1];

    for (i = 0; i < (SPECK_KEY_LEN - 1); i++)
    {
        a[i] = K[i + 1];
    }
    S[0] = b;
    for (i = 0; i < SPECK_ROUNDS - 1; i++) {
        R(a[i % (SPECK_KEY_LEN - 1)], b, i);
        S[i + 1] = b;
    }
}

void speck_encrypt(SPECK_TYPE const pt[static 2], SPECK_TYPE ct[static 2], SPECK_TYPE const K[static SPECK_ROUNDS])
{
    SPECK_TYPE i;
    ct[0] = pt[0]; ct[1] = pt[1];

    for (i = 0; i < SPECK_ROUNDS; i++) {
        R(ct[1], ct[0], K[i]);
    }
}

void speck_decrypt(SPECK_TYPE const ct[static 2], SPECK_TYPE pt[static 2], SPECK_TYPE const K[static SPECK_ROUNDS])
{
    SPECK_TYPE i;
    pt[0] = ct[0]; pt[1] = ct[1];

    for (i = 0; i < SPECK_ROUNDS; i++) {
        RR(pt[1], pt[0], K[(SPECK_ROUNDS - 1) - i]);
    }
}

void (*speck_expand_ptr)(SPECK_TYPE const K[static SPECK_KEY_LEN], SPECK_TYPE S[static SPECK_ROUNDS]) = speck_expand;
void (*speck_encrypt_ptr)(SPECK_TYPE const pt[static 2], SPECK_TYPE ct[static 2], SPECK_TYPE const K[static SPECK_ROUNDS]) = speck_encrypt;
void (*speck_decrypt_ptr)(SPECK_TYPE const ct[static 2], SPECK_TYPE pt[static 2], SPECK_TYPE const K[static SPECK_ROUNDS]) = speck_decrypt;

int main(void) {
    WDTCTL = WDTPW | WDTHOLD; // 停止看门狗定时器

    uart_init();
    uart_puts("eval_crypto_process\n");

    // 配置 GPIO
    P2DIR |= BIT0 | BIT1; // P2.0 = MOSI, P2.1 = MISO
    P2OUT = 0x00; // 初始化为低

    
    uart_puts("Waiting.\n");

    __delay_cycles(5000 * (MCLK_FREQ / 1000000)); // 5 秒延时

    uart_puts("Starting crypto.\n");

    // P2.0 高
    P2OUT = BIT0;

    uint16_t plain[2] = {54321, 54321}; // 调整为 16 位数据
    uint16_t key[4] = {12345, 12345, 12345, 12345}; // 调整为 16 位密钥

    SPECK_TYPE buffer[2] = {0};
    SPECK_TYPE enc[2] = {0};

    SPECK_TYPE exp[SPECK_ROUNDS];

    speck_expand_ptr(key, exp);
    speck_encrypt_ptr(plain, enc, exp);
    speck_decrypt_ptr(enc, buffer, exp);

    // P2.0 低
    P2OUT = 0x00;
    
    uart_puts("finished crypto.\n");
}
