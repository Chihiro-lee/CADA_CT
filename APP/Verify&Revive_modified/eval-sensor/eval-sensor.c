#include <RAhook.h>
typedef unsigned char uint8_t;
typedef int int16_t;
typedef unsigned long uint32_t;
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

/**************** SIMULATED TEMPERATURE DATA ******************/
#define TEMP_SLA_ADDR 0x40

int main(void) {
    WDTCTL = WDTPW | WDTHOLD; // 停止看门狗定时器

    uint8_t buf[2];
    uint32_t conv_buf;
    int16_t temp;

    uart_init();
    uart_puts("eval_sensor_process\n");

    // 配置 GPIO
    P2DIR |= BIT0 | BIT2; // P2.0 = MOSI, P2.2 = PB4 替代
    P2OUT |= BIT2; // 设置 P2.2 高（对应 PB4）

    uart_puts("Waiting.\n");
    __delay_cycles(5000 * (MCLK_FREQ / 1000000)); // 5 秒延时

    // MOSI 高
    uart_puts("Starting sampling\n");
    P2OUT = BIT0 | BIT2; // MOSI (P2.0) 高，保持 P2.2 高

    // 模拟输入温度数据（0x3A98 对应约 25°C）
    buf[0] = 0x3A; // 高字节
    buf[1] = 0x98; // 低字节

    // 温度转换（来自 Contiki sht25.c 驱动）
    conv_buf = (uint32_t)(((buf[0] << 8) + buf[1]) & ~0x0003);
    conv_buf *= 17572;
    conv_buf = conv_buf >> 16;
    temp = (int16_t)conv_buf - 4685;

    // MOSI 低
    P2OUT = BIT2; // MOSI 低，保持 P2.2 高
    uart_puts("Finished sampling\n");

    // 通过 UART 输出温度值
    uart_putchar((uint8_t)((temp & 0xFF00) >> 8));
    uart_putchar((uint8_t)(temp & 0x00FF));
}
