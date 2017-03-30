module tm_gen (
	input clk,
	input n_rst,
	output tm,
	output pre_tm
);

`include "src/code/vh/hsi_master_config.vh"	 

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
 
 tm_cntr TM_CNTR (
	.clk(clk), 
	.n_rst(n_rst),
	.tm(tm),
	.pre_tm_en(PRE_TM_EN)
 );
 
parameter CCW_TX_TIME = (`TX_FREQ == `Mbps_1) ? ((`CLK_FREQ/1000000)*748) : ((`CLK_FREQ/1000000)*5984);
 
parameter PRE_TM_TIME_FOR_TM_1HZ  = `CLK_FREQ - CCW_TX_TIME - 1,
			 PRE_TM_TIME_FOR_TM_10HZ = ((`CLK_FREQ) / 10) - CCW_TX_TIME - 1;
			 
parameter PRE_TM_TIME = (`TM_FREQ == `Hz_1) ? PRE_TM_TIME_FOR_TM_1HZ : PRE_TM_TIME_FOR_TM_10HZ;

assign pre_tm = PRE_TM_EN ? ((ticks >= (PRE_TM_TIME - 2 /*** 3 чтобы УКС передавалась вплоть до метки времени ***/)) & ~tm) : 0;

parameter TICKS_IN_1_SEC = ((`CLK_FREQ) - 1), 
			 TICKS_IN_100_MSEC = (((`CLK_FREQ) / 10) - 1);
			 
reg[25:0] ticks; 			 
assign tm = (`TM_FREQ == `Hz_1) ? (ticks == TICKS_IN_1_SEC) : (ticks == TICKS_IN_100_MSEC); 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ticks = 0;
	else 
		begin
			if(tm)
				ticks = 0;
			else
				ticks = ticks + 1;
		end
end

endmodule

module tm_cntr (
	input clk,
	input n_rst,
	input tm,
	output pre_tm_en
); 

assign pre_tm_en = (`TM_FREQ == `Hz_1) ? 1 : tmp;

reg tmp;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tmp = 0;
	else if(tm_cntr == 9)
		tmp = 1;
	else if(tm_10th)
		tmp = 0;
end

reg[3:0] tm_cntr;
wire tm_10th = (tm_cntr == 10);
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tm_cntr = 0;
	else if(tm_10th)
		tm_cntr = 0;
	else if(tm)
		tm_cntr = tm_cntr + 1;
end
endmodule 