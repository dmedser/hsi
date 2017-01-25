module reset_controller (
	input 	  clk,
	output reg n_rst
);

`define CLK_FREQ 			24000000
`define RESET_TIME_SEC	4 

reg[26:0] ticks;
parameter TICKS_IN_4_SEC = (`CLK_FREQ) * (`RESET_TIME_SEC);

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