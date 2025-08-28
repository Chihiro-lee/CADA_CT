#ifndef HEADER_FILE_RA_HOOK
#define HEADER_FILE_RA_HOOK

#include <msp430.h>

#define callSendUpdate() ({asm("BR #0xff12");})
#define callSendXor() ({asm("BR #0xff16");})


//typedef unsigned long uint32_t;
//volatile uint32_t tmp_dfi_r7 = 0;


void initUART() {

    WDTCTL = WDTPW | WDTHOLD;
    
    __dint();
    
    P4SEL |= BIT4+BIT5;    
    UCA1CTL1 |= UCSWRST;
    UCA1CTL1 |= UCSSEL_1;

    //Set the baudrate
    UCA1BR0 = 3;
    UCA1MCTL = 0xD6;
    UCA1CTL0 = 0x00;
    UCA1CTL1 &= ~UCSWRST;  
    
    UCA1IE |= UCRXIE;
    
    __bis_SR_register(GIE);
}

void __attribute__((interrupt(USCI_A1_VECTOR))) USCI_A1_ISR(void) {
    switch(__even_in_range(UCA1IV,4)) {
    case 0:break;                             
    case 2: 
        if (UCA1RXBUF == 'x') { //xor_compute
            //UCA1IE &= ~UCRXIE;
            callSendXor();
            break;
        }
        if (UCA1RXBUF == 'r') { //receive_update
            //UCA1IE &= ~UCRXIE;
            callSendUpdate();
            break;
        }
        if (UCA1RXBUF == 's') { //stop_app
            //UCA1IE &= ~UCRXIE;
            WDTCTL = 6; //reset MCU
            break;
        }
        //
        break;
    case 4:break;                             
    default: break;
    }
}
#endif
