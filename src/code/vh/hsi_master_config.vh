/********** HSI MASTER CONFIG **********/

`define CLK_FREQ 		48000000
`define RST_TIME_SEC	4 
`define BTC_SEND_DELAY_TICKS (4800 - 1) // 100 мкс

/******************** Частота передачи ********************/ 
`define Mbps_6   6
`define Mbps_1   1
`define Kbps_125 125 

`define TX_FREQ 1

`define TX_DIV_FACTOR ((`TX_FREQ == `Mbps_1) ? (48 - 1) : (384 - 1))

/********************* Частота приема *********************/
`define RX_FREQ 1

`define RX_DIV_FACTOR ((`RX_FREQ == `Mbps_6) ? (1 - 1) : ((`RX_FREQ == `Mbps_1) ? (6 - 1) : (48 - 1)))
// 6 МБит/с   (x8 = 48 МБит/с) 
// 1 МБит/с   (x8 = 8  МБит/с)
// 125 КБит/с (x8 = 1  МБит/с)

`define Hz_1  1
`define Hz_10 10

`define TM_FREQ 1

`define LSB 0
`define MSB 1

`define ML_FST 0