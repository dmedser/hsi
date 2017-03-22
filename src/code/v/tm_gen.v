module tm_gen (
	input clk,
	input n_rst,
	output tm,
	output pre_tm
);

`include "src/code/vh/hsi_master_config.vh"	 

parameter TICKS_IN_1_SEC = ((`CLK_FREQ) - 1), 
			 TICKS_IN_100_MSEC = (((`CLK_FREQ) / 10) - 1); 

reg[25:0] ticks; 			 
assign tm = (`TM_FREQ == `HZ_1) ? (ticks == TICKS_IN_1_SEC) : (ticks == TICKS_IN_100_MSEC);
 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			ticks = 0;
		end
	else 
		begin
			if(tm)
				begin
					ticks = 0;
				end
			else
				begin
					ticks = ticks + 1;
				end
		end
end

endmodule 