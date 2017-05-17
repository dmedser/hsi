/********** HSI CONFIG **********/

`define CLK_FREQ 		48000000
`define RST_TIME_SEC	4 

/******************** Частота передачи ********************/ 
`define Mbps_6   6
`define Mbps_1   1
`define Kbps_125 125 

`define M_TX_FREQ (`Mbps_1)
`define M_TX_DIV_FACTOR ((`M_TX_FREQ == `Mbps_1) ? (48 - 1) : (384 - 1))

/********************* Частота приема *********************/

`define M_RX_FREQ (`S_TX_FREQ)
`define M_RX_DIV_FACTOR ((`S_TX_FREQ == `Mbps_6) ? (1 - 1) : ((`S_TX_FREQ == `Mbps_1) ? (6 - 1) : (48 - 1)))
// 6 МБит/с   (x8 = 48 МБит/с) 
// 1 МБит/с   (x8 = 8  МБит/с)
// 125 КБит/с (x8 = 1  МБит/с)

`define Hz_1  1
`define Hz_10 10

`define TM_FREQ (`Hz_1)

`define LSB 0
`define MSB 1

`define ML_FST (`LSB)

`define S_TX_FREQ (`Mbps_1) 
`define S_TX_DIV_FACTOR ((`S_TX_FREQ == `Mbps_6) ? (8 - 1) : ((`S_TX_FREQ == `Mbps_1) ? (48 - 1) : (384 - 1)))

`define S_RX_FREQ (`M_TX_FREQ)
`define S_RX_DIV_FACTOR ((`M_TX_FREQ == `Mbps_1) ? (6 - 1) : (48 - 1))

`define CCW_LEN 16

`define S_DP_LEN 6
`define S_DP_COUNT 1