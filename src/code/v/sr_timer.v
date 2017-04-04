module sr_timer (
	input clk,
	input n_rst,
	output time4sr
);

`include "src/code/vh/hsi_master_config.vh"	  

parameter TICKS_IN_50_MSEC  = (((`CLK_FREQ/1000)*50) - 1),
			 TICKS_IN_100_MSEC = (((`CLK_FREQ/1000)*100) - 1);

assign time4sr = ((ticks == TICKS_IN_50_MSEC) & ~offset_50ms) | (ticks == TICKS_IN_100_MSEC);
  
reg tmp;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tmp = 0;
	else if(offset_50ms)
		tmp = 1;
end

wire offset_50ms_rst = offset_50ms & ~tmp; 

reg offset_50ms;			 
reg[22:0] ticks;
always@(posedge clk or negedge n_rst or posedge offset_50ms_rst)
begin
	if(n_rst == 0)
		ticks = 0;
	else if(offset_50ms_rst)
		ticks = 0;
	else if(ticks == TICKS_IN_100_MSEC)
		ticks = 0;
	else 
		ticks = ticks + 1;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		offset_50ms = 0;
	else if(ticks == TICKS_IN_50_MSEC)
		offset_50ms = 1;
end	

endmodule