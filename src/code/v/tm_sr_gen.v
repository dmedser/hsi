module tm_sr_gen (
	input clk,
	input n_rst,
	output reg tm_tx_rdy,
	input      tm_tx_ack,
	output reg sr_tx_rdy,
	input      sr_tx_ack,
	input      sr_repeat_req,
	output pre_tm,
	output l00_ms_is_left
);

`include "src/code/vh/hsi_config.vh"	 

/*
 * +-------------------+------------------------+
 *	| Скорость передачи |     Время передачи     |
 *	|					     | фрейма данных (11 бит) |
 *	+-------------------+------------------------+
 *	|      1 МБит/с     | 		  11 мкс          |
 * +-------------------+------------------------+                  
 * |     125 КБит/с    | 		  88 мкс          |
 * +-------------------+------------------------+  
 *
 *	+-------------------+--------------------+
 *	|                   | Время передачи УКС |
 *	| Скорость передачи |   (4 service +     |
 *	|						  |  62 data + 2 CRC)  |
 *	+-------------------+--------------------+
 *	|      1 МБит/с     |       748 мкс      |
 * +-------------------+--------------------+
 *	|     125 КБит/с    |       5984 мкс     |
 * +-------------------+--------------------+
 *
 */
assign l00_ms_is_left = l00_MS_IS_LEFT; 
 
tim_100_ms_tm TIM_100_MS (
	.clk(clk),
	.n_rst(n_rst),
	.l00_ms_is_left(l00_MS_IS_LEFT),
	.pre_tm_en(PRE_TM_EN),
	.tm(TM),
	.pre_tm(PRE_TM)
);

assign pre_tm = PRE_TM;

tm_alert TM_ALERT (
	.clk(clk),
	.n_rst(n_rst),
	.l00_ms_is_left(l00_MS_IS_LEFT),
	.tm(TM),
	.pre_tm_en(PRE_TM_EN)
);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tm_tx_rdy = 0;
	else if(TM)
		tm_tx_rdy = 1;
	else if(tm_tx_ack)
		tm_tx_rdy = 0;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		sr_tx_rdy = 0;
	else if(l00_MS_IS_LEFT | sr_repeat_req)
		sr_tx_rdy = 1;
	else if(sr_tx_ack)
		sr_tx_rdy = 0;
end

endmodule


module tim_100_ms_tm (
	input clk,
	input n_rst,
	output l00_ms_is_left,
	input pre_tm_en,
	input tm,
	output pre_tm
);
parameter TICKS_IN_100_MS = (((`CLK_FREQ) / 10) - 1);
assign l00_ms_is_left = (ticks == TICKS_IN_100_MS);
reg[22:0] ticks;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ticks = 0;
	else if(l00_ms_is_left)
		ticks = 0;
	else 
		ticks = ticks + 1;
end
parameter CCW_TX_TIME = (`M_TX_FREQ == `Mbps_1) ? ((`CLK_FREQ/1000000)*748) : ((`CLK_FREQ/1000000)*5984),
			 PRE_TM_TIME = ((`CLK_FREQ) / 10) - CCW_TX_TIME - 1;
assign pre_tm = pre_tm_en ? ((ticks >= (PRE_TM_TIME - 2)) & ~tm) : 0;
endmodule


module tm_alert (
	input clk,
	input n_rst,
	input l00_ms_is_left,
	output tm,
	output pre_tm_en
);
assign tm = (`TM_FREQ == `Hz_1) ? l0th_tm : l00_ms_is_left;
wire l0th_tm = (tm_cntr == 9) & l00_ms_is_left;
reg[3:0] tm_cntr;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tm_cntr = 0;
	else if(l0th_tm)
		tm_cntr = 0;
	else if(l00_ms_is_left)
		tm_cntr = tm_cntr + 1;
end
assign pre_tm_en = (`TM_FREQ == `Hz_1) ? tmp : 1;
reg tmp;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tmp = 0;
	else if(tm_cntr == 9)
		tmp = 1;
	else if(l0th_tm)
		tmp = 0;
end
endmodule
