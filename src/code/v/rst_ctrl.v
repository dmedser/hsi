module reset_controller (
	input 	  clk,
	output reg n_rst
);

`include "src/code/vh/hsi_config.vh"		

reg[27:0] ticks;

parameter TICKS_IN_4_SEC = (((`CLK_FREQ) * (`RST_TIME_SEC)) - 1);

always@(posedge clk)
begin
	if(ticks < TICKS_IN_4_SEC)
		begin
			ticks = ticks + 1;
			n_rst = 0;
		end
	else
		begin
			n_rst = 1;
		end
end

endmodule