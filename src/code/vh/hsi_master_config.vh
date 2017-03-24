/********** HSI MASTER CONFIG **********/

`define CLK_FREQ 		48000000
`define RST_TIME_SEC	4 
`define BTC_SEND_DELAY_TICKS (4800 - 1) // 100 мкс

/******************** Частота передачи ********************/ 
`define TX_DIV_FACTOR (48 - 1)    //   1 МБит/с
//`define TX_DIV_FACTOR (384 - 1) // 125 КБит/с

/********************* Частота приема *********************/
//`define RX_DIV_FACTOR (1 - 1)  // 6 МБит/с   (x8 = 48 МБит/с) 
`define RX_DIV_FACTOR (6 - 1)    // 1 МБит/с   (x8 = 8  МБит/с)
//`define RX_DIV_FACTOR (48 - 1) // 125 КБит/с (x8 = 1  МБит/с)

`define HZ_1  1
`define HZ_10 10

`define TM_FREQ 1

`define LSB 0
`define MSB 1

`define ML_FST 0