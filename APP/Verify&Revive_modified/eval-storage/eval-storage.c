#include <RAhook.h>
typedef unsigned char uint8_t;
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
    while (!(UCA1IFG & UCTXIFG)); // 等待 TX 缓冲区就绪
    UCA1TXBUF = c; // 发送字符
}

void uart_puts(char *c) {
    while (*c) {
        if (*c == '\n')
            uart_putchar('\r');
        uart_putchar(*c++);
    }
}

/**************** READ AND WRITE TO FLASH (EEPROM EQUIVALENT) ******************/

int main(void) {
    WDTCTL = WDTPW | WDTHOLD; // 停止看门狗定时器

    uint8_t wr_array[256];
    uint8_t rd_array[256];

    uart_init();
    uart_puts("eval_storage_process\n");

    // 配置 GPIO
    P2DIR |= BIT0 | BIT1; // P2.0 = MOSI, P2.1 = MISO
    P2OUT = 0x00; // 初始化为低

    // 生成数据
    uint16_t i;
    for (i = 0; i < 256; i++) {
        wr_array[i] = i + 5;
    }

    // 执行一次
    __delay_cycles(5000 * (MCLK_FREQ / 1000000)); // 5 秒延时

    uart_puts("Start writing\n");
    P2OUT = BIT0; // MOSI 高

    // 擦除 Info B 段（0x1800-0x18FF）
    FCTL3 = FWKEY; // 解锁 Flash
    FCTL1 = FWKEY | ERASE; // 启用擦除
    *(uint16_t *)0x1800 = 0; // 触发段擦除
    FCTL1 = FWKEY; // 禁用擦除
    FCTL3 = FWKEY | LOCK; // 锁定 Flash

    // 写入 Flash
    FCTL3 = FWKEY; // 解锁 Flash
    FCTL1 = FWKEY | WRT; // 启用写入
    for (i = 0; i < 256; i += 2) { // 按 16 位写入
        *(uint16_t *)(0x1800 + i) = (wr_array[i + 1] << 8) | wr_array[i];
    }
    FCTL1 = FWKEY; // 禁用写入
    FCTL3 = FWKEY | LOCK; // 锁定 Flash

    P2OUT = 0x00; // MOSI 低
    uart_puts("end writing\n");

    __delay_cycles(500 * (MCLK_FREQ / 1000000)); // 0.5 秒延时

    uart_puts("start reading\n");
    P2OUT = BIT0; // MOSI 高

    // 读取 Flash
    for (i = 0; i < 256; i++) {
        rd_array[i] = *(uint8_t *)(0x1800 + i);
    }

    P2OUT = 0x00; // MOSI 低
    uart_puts("end reading\n");
}
