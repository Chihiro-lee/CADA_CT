typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long uint32_t;
typedef signed long int32_t;
typedef signed int int16_t;
typedef signed char int8_t;
typedef unsigned char bool;
typedef unsigned long long uint64_t;

const uint16_t appBottomText          = 0x4400;
const uint16_t appTopText             = 0xc3ff;

uint16_t* UCA1TXBUF              = 0x060E;
uint16_t* FCTL3                  = 0x0144;

const char hex_chars[] = "0123456789ABCDEF";

uint16_t address_key;
uint32_t address_xor;
uint32_t address_sr;
uint32_t address_pc;

uint8_t instruction_mode;
uint16_t verify_count;
uint16_t write_count;
uint16_t write_address_value;
uint16_t count_add;

uint8_t write_count_bytes[2];
uint8_t count_add_bytes[2];
uint8_t combined_bytes[10];
uint8_t instruction_mode_bytes[1];
uint8_t address_pc_bytes[4];

uint16_t tmp_r4 = 0;
uint16_t tmp_r5 = 0;
uint16_t tmp_r6 = 0;

uint16_t* reg_r4;
uint16_t* reg_r5;
uint16_t* reg_r6;
uint16_t* reg_r8;
uint16_t* reg_sr;
uint16_t* reg_sp;
uint16_t* dest;
uint16_t* writeAddress;

const uint16_t write_count_address = 0x2822;
const uint16_t address_xor_address = 0x2930;

/* *****uart send model***** */

/*@ requires \valid(bytes + (0 .. 1));
    assigns bytes[0 .. 1];
    assigns *(bytes+ (0 .. 1));
    ensures bytes[0] == (uint8_t)((value >> 8) & 0xFF);
    ensures bytes[1] == (uint8_t)(value & 0xFF);
*/
void uint16_to_bytes(uint16_t value, uint8_t bytes[2]) {
    bytes[0] = (value >> 8) & 0xFF;
    bytes[1] = value & 0xFF;
}

/*@ requires \valid(bytes + (0 .. 3));
    assigns bytes[0 .. 3];
    assigns *(bytes+ (0 .. 3));
    ensures bytes[0] == (uint8_t)((value >> 24) & 0xFF);
    ensures bytes[1] == (uint8_t)((value >> 16) & 0xFF);
    ensures bytes[2] == (uint8_t)((value >> 8) & 0xFF);
    ensures bytes[3] == (uint8_t)(value & 0xFF);
*/
void uint32_to_bytes(uint32_t value, uint8_t bytes[4]) {
    bytes[0] = (value >> 24) & 0xFF;
    bytes[1] = (value >> 16) & 0xFF;
    bytes[2] = (value >> 8) & 0xFF;
    bytes[3] = value & 0xFF;
}

/*@ requires \valid(bytes + (0 .. 7));
    assigns bytes[0 .. 7];
    assigns *(bytes+ (0 .. 7));
    ensures bytes[0] == (uint8_t)((value >> 56) & 0xFF);
    ensures bytes[1] == (uint8_t)((value >> 48) & 0xFF);
    ensures bytes[2] == (uint8_t)((value >> 40) & 0xFF);
    ensures bytes[3] == (uint8_t)((value >> 32) & 0xFF);
    ensures bytes[4] == (uint8_t)((value >> 24) & 0xFF);
    ensures bytes[5] == (uint8_t)((value >> 16) & 0xFF);
    ensures bytes[6] == (uint8_t)((value >> 8) & 0xFF);
    ensures bytes[7] == (uint8_t)(value & 0xFF);
*/
void uint64_to_bytes(uint64_t value, uint8_t bytes[8]) {
    bytes[0] = (value >> 56) & 0xFF;
    bytes[1] = (value >> 48) & 0xFF;
    bytes[2] = (value >> 40) & 0xFF;
    bytes[3] = (value >> 32) & 0xFF;
    bytes[4] = (value >> 24) & 0xFF;
    bytes[5] = (value >> 16) & 0xFF;
    bytes[6] = (value >> 8) & 0xFF;
    bytes[7] = value & 0xFF;
}

/*@  assigns \nothing;  
     ensures high == \old(high);
     ensures low == \old(low);
*/
uint64_t combine_uint32_to_uint64(uint32_t high, uint32_t low) {
    return ((uint64_t)high << 32) | low;
}

/*@ requires \valid(UCA1TXBUF);
    assigns *UCA1TXBUF;
    ensures *UCA1TXBUF == byte;
*/
void uart_send_byte(uint8_t byte) {
    *UCA1TXBUF = byte;
}

/*@ requires 0 <= index < 16;
    assigns \nothing;
    ensures \result == hex_chars[index];
*/
uint8_t get_hex_char(uint8_t index) {
    return hex_chars[index];
}

/*@ requires \valid(data + (0 .. length-1)); 
    requires \forall integer k; 0 <= k < length ==> \valid(data + k);
    requires \valid(UCA1TXBUF);
    requires length > 0;
    requires \separated(data + (0 .. length-1), UCA1TXBUF);
    assigns *UCA1TXBUF;
    assigns data[0 .. length-1];
    assigns *(data+ (0 .. length-1));
    ensures *UCA1TXBUF == 0x20;
*/
void uart_send_hex_data(uint8_t *data, uint8_t length) {
    /*@ loop invariant 0 <= i <= length;
        loop invariant \forall integer j; 0 <= j < i ==> \valid(data + j);
        loop assigns i, *UCA1TXBUF;
        loop variant length - i;
    */
    for (uint8_t i = 0; i < length; i++) {
        //@ assert \valid(data + i);
        uint8_t index_high = (data[i] >> 4) & 0x0F;
        uint8_t index_low = data[i] & 0x0F;
        //@ assert 0 <= index_high < 16;
        //@ assert 0 <= index_low < 16;
        uint8_t c_high = get_hex_char(index_high);
        uint8_t c_low  = get_hex_char(index_low);
        uart_send_byte(c_high);
        uart_send_byte(c_low);
    }
    uart_send_byte(0x20); 
}

/* *****uart send model***** */


/* *****XOR API model***** */

//instruction_mode_bytes[0];
//assigns address_pc_bytes[0 .. 3];
//assigns address_pc;

/*@ requires \valid(UCA1TXBUF);
    requires instruction_mode == 0 || instruction_mode == 1 || instruction_mode == 2 || instruction_mode == 3;
    assigns combined_bytes[0 .. 9];
    assigns *UCA1TXBUF;
    ensures address_xor == \old(address_xor);
    ensures address_sr == \old(address_sr);
    ensures write_count == \old(write_count);
    ensures *UCA1TXBUF == 0x0D;
    ensures address_xor_address < 0x4400 || address_xor_address > 0xc3ff;
*/
void XorResult() {  
    
    /*@ loop invariant 0 <= j <= 300;
        loop invariant \forall integer k; 0 <= k < 300 ==> \at(combined_bytes[k], Pre) == \at(combined_bytes[k], Here);
        loop invariant \at(instruction_mode_bytes[0], Pre) == \at(instruction_mode_bytes[0], Here);
        loop invariant \forall integer k; 0 <= k < 4 ==> \at(address_pc_bytes[k], Pre) == \at(address_pc_bytes[k], Here);
        loop invariant \at(*UCA1TXBUF, Pre) == \at(*UCA1TXBUF, Here);
        loop assigns j;
        loop variant 300 - j;
    */
    for (int j = 0; j < 300; j++) {
        // __asm("nop")
    }

    uint64_t combined = combine_uint32_to_uint64(address_sr, address_xor);
    uint64_to_bytes(combined, combined_bytes);
    uint16_to_bytes(verify_count, combined_bytes+8);
    uart_send_hex_data(combined_bytes, 10);

    //instruction_mode_bytes[0] = instruction_mode & 0xFF;
    //uart_send_hex_data(instruction_mode_bytes, 1);

    /*if (instruction_mode == 0 || instruction_mode == 1) {
        address_pc += 4;
        uint32_to_bytes(address_pc, address_pc_bytes);
        uart_send_hex_data(address_pc_bytes, 4);
    }*/

    uart_send_byte(0x54);
    uart_send_byte(0x0A);
    uart_send_byte(0x0D); 
    //@ assert address_xor_address < 0x4400 || address_xor_address > 0xc3ff;
}

//  instruction_mode_bytes[0];
//  address_pc
//  address_pc_bytes[0 .. 3];
/*@
  requires \valid(dest);
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(UCA1TXBUF);
  requires \separated(UCA1TXBUF,reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, dest);
  assigns tmp_r4, tmp_r5, tmp_r6, instruction_mode, write_count;
  assigns *reg_r4, *reg_r5, *reg_r6, *reg_r8, *reg_sr, *dest;
  assigns address_key, address_xor, address_sr, verify_count;
  assigns combined_bytes[0 .. 9];
  assigns *UCA1TXBUF;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures *reg_r6 == \old(*reg_r6);
  ensures *reg_r8 == write_count;
  ensures *reg_sr == *reg_r4;
  ensures instruction_mode == 0;
  ensures *dest == *reg_r6;  
  ensures address_xor_address < 0x4400 || address_xor_address > 0xc3ff; 
*/
void safe_call_fun(uint16_t* reg_r4, uint16_t* reg_r5,uint16_t* reg_r6,uint16_t* reg_r8, uint16_t* reg_sr) {

    tmp_r4 = *reg_r4;
    tmp_r6 = *reg_r6;
    tmp_r5 = *reg_r5;


    address_xor = (*reg_r6) ^ address_key;
    address_sr = (*reg_r4) ^ address_key;
    instruction_mode = 0;
    verify_count += 1;
    write_count = *reg_r8;
    //@ assert instruction_mode == 0;
    XorResult();
    //@ assert *UCA1TXBUF == 0x0D;
    *reg_r8 = write_count;
    *reg_r4 = tmp_r4;
    *reg_r6 = tmp_r6;
    *reg_sr = *reg_r4;
    
    *dest = *reg_r6;   
}

/*@
  requires \valid(dest);
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(UCA1TXBUF);
  requires \separated(UCA1TXBUF,reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, dest);
  assigns tmp_r4, tmp_r5, tmp_r6, instruction_mode, write_count;
  assigns *reg_r4, *reg_r5, *reg_r6, *reg_r8, *reg_sr, *dest;
  assigns address_key, address_xor, address_sr, verify_count;
  assigns combined_bytes[0 .. 9];
  assigns *UCA1TXBUF;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures *reg_r6 == \old(*reg_r6);
  ensures *reg_r8 == write_count;
  ensures *reg_sr == *reg_r4;
  ensures instruction_mode == 1;
  ensures *dest == *reg_r6;  
  ensures address_xor_address < 0x4400 || address_xor_address > 0xc3ff; 
*/
void safe_calla_fun(uint16_t* reg_r4, uint16_t* reg_r5,uint16_t* reg_r6,uint16_t* reg_r8, uint16_t* reg_sr) {

    tmp_r4 = *reg_r4;
    tmp_r6 = *reg_r6;
    tmp_r5 = *reg_r5;


    address_xor = (*reg_r6) ^ address_key;
    address_sr = (*reg_r4) ^ address_key;
    instruction_mode = 1;
    verify_count += 1;
    write_count = *reg_r8;
    //@ assert instruction_mode == 1;
    XorResult();
    //@ assert *UCA1TXBUF == 0x0D;
    *reg_r8 = write_count;
    *reg_r4 = tmp_r4;
    *reg_r6 = tmp_r6;
    *reg_sr = *reg_r4;
    
    *dest = *reg_r6;   
}
//instruction_mode_bytes[0];
//address_pc
//address_pc_bytes[0 .. 3];

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(reg_sp);
  requires \valid(UCA1TXBUF);
  requires \separated(UCA1TXBUF, reg_r4, reg_r6, reg_r8, reg_sr, reg_sp);
  assigns tmp_r4, write_count, instruction_mode;
  assigns *reg_r4, *reg_r6, *reg_sp, *reg_r8, *reg_sr;
  assigns address_key, address_xor, address_sr, verify_count;
  assigns combined_bytes[0 .. 9];
  assigns *UCA1TXBUF;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r6 == *reg_sp;
  ensures *reg_r8 == write_count;
  ensures *reg_sr == *reg_r4;
  ensures instruction_mode == 2;
  ensures address_xor_address < 0x4400 || address_xor_address > 0xc3ff;
*/
void safe_ret_fun(uint16_t* reg_r4, uint16_t* reg_sp,uint16_t* reg_r8, uint16_t* reg_sr){
    tmp_r4 = *reg_r4;
    *reg_r6 = *reg_sp;
    address_xor = (*reg_r6) ^ address_key;
    address_sr = (*reg_r4) ^ address_key;
    instruction_mode = 2;
    verify_count += 1;
    write_count = *reg_r8;
    //@ assert instruction_mode == 2;
    XorResult();
    //@ assert *UCA1TXBUF == 0x0D;
    *reg_r8 = write_count;
    *reg_r4 = tmp_r4;
    *reg_sr = *reg_r4;
    //@ assert address_xor_address < 0x4400 || address_xor_address > 0xc3ff;
    return;
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(reg_sp);
  requires \valid(UCA1TXBUF);
  requires \separated(UCA1TXBUF, reg_r4, reg_r6, reg_r8, reg_sr, reg_sp);
  assigns tmp_r4, write_count, instruction_mode;
  assigns *reg_r4, *reg_r6, *reg_sp, *reg_r8, *reg_sr;
  assigns address_key, address_xor, address_sr, verify_count;
  assigns combined_bytes[0 .. 9];
  assigns *UCA1TXBUF;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r6 == *reg_sp;
  ensures *reg_r8 == write_count;
  ensures *reg_sr == *reg_r4;
  ensures instruction_mode == 3;
  ensures address_xor_address < 0x4400 || address_xor_address > 0xc3ff;
*/
void safe_reta_fun(uint16_t* reg_r4, uint16_t* reg_sp,uint16_t* reg_r8, uint16_t* reg_sr){
    tmp_r4 = *reg_r4;
    *reg_r6 = *reg_sp;
    address_xor = (*reg_r6) ^ address_key;
    address_sr = (*reg_r4) ^ address_key;
    instruction_mode = 3;
    verify_count += 1;
    write_count = *reg_r8;
    //@ assert instruction_mode == 3;
    XorResult();
    //@ assert *UCA1TXBUF == 0x0D;
    *reg_r8 = write_count;
    *reg_r4 = tmp_r4;
    *reg_sr = *reg_r4;
    //@ assert address_xor_address < 0x4400 || address_xor_address > 0xc3ff;
    return;
}
/* *****XOR API model***** */


/* *****secureSend API model***** */
/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_r6 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_mov_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 = *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_r6 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_movx_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 = *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_xor_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 ^= *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_xorx_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 ^= *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_add_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 += *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}


/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_addx_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 += *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_addc_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 += *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_addcx_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 += *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_dadd_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 += *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_daddx_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 += *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_sub_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 -= *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_subx_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 -= *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_subc_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 -= *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@
  requires \valid(reg_r4);
  requires \valid(reg_r5);
  requires \valid(reg_r6);
  requires \valid(reg_r8);
  requires \valid(reg_sr);
  requires \valid(FCTL3);
  requires \separated(reg_r4, reg_r5, reg_r6, reg_r8, reg_sr, FCTL3);
  assigns *reg_r6, *reg_r8, *reg_sr;
  ensures *reg_r4 == \old(*reg_r4);
  ensures *reg_r5 == \old(*reg_r5);
  ensures reg_r6 != FCTL3 ==> *reg_sr == *reg_r4;
  ensures 0 <= *reg_r8 <= 65536;
  ensures write_count_address < 0x4400;
*/
void write_subcx_fun(uint16_t* reg_r4, uint16_t* reg_r5, uint16_t* reg_r6, uint16_t* reg_r8, uint16_t* reg_sr) {

    if (reg_r6 == FCTL3) {   
        return;  
    }
    
    *reg_r6 -= *reg_r5; 
    //@ assert *reg_r8 == \at(*reg_r8,Pre);
    *reg_r8 = (*reg_r8) + 1;              
    *reg_sr = *reg_r4;

    //@ assert write_count_address < 0x4400;
    return; 
}

/*@ requires \valid(UCA1TXBUF);
    requires \valid(writeAddress);
    requires \valid(reg_r8);
    requires \separated(UCA1TXBUF, reg_r8, writeAddress);
    assigns *writeAddress, write_count_bytes[0 .. 1], count_add_bytes[0 .. 1], count_add;
    assigns *UCA1TXBUF, *reg_r8;
    ensures write_count == \old(write_count);
    ensures address_xor == \old(address_xor);
    ensures *writeAddress != write_count ==> *writeAddress == *reg_r8;	
    ensures *UCA1TXBUF == 0x0D;
    ensures write_count_address < 0x4400;
*/
void secureSend(){
    
    if (*writeAddress != write_count){
    	*writeAddress = *reg_r8;	
    }
    count_add = count_add + write_count;
    uint16_to_bytes(write_count, write_count_bytes);
    uint16_to_bytes(count_add, count_add_bytes);
    uart_send_hex_data(write_count_bytes, 2);
    uart_send_byte(0x0A);
    uart_send_byte(0x0D);
    
    uart_send_hex_data(count_add_bytes, 2);
    uart_send_byte(0x0A);
    uart_send_byte(0x0D);
    //@ assert write_count_address < 0x4400;
}
