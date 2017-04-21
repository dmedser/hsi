module ccw_emgc_ctrl (
	input clk,
	input n_rst, 
	input ccw_accepted,
	input sd_busy,
	input no_reply_or_err,
	output repeat_req,
	output switch_com_src_req
);

`include "src/code/vh/hsi_config.vh"

wire REPEAT_DELAY_START = sd_busy & (RPT_CNTR < 3);
wire REPEAT_DELAY_IS_OVER;

assign repeat_req = REPEAT_DELAY_IS_OVER | no_reply_or_err;
assign switch_com_src_req = no_reply_or_err;

rpt_delay_100_ms REPEAT_DELAY_100_MS (
	.clk(clk),
	.n_rst(n_rst),
	.start(REPEAT_DELAY_START),
	.stop(REPEAT_DELAY_IS_OVER)
);

rpt_by_sd_busy_cntr REPEAT_CONUTER (
	.incr(REPEAT_DELAY_START),
	.rst(ccw_accepted),
	.cntr(RPT_CNTR)
);
wire[1:0] RPT_CNTR; 

endmodule



module rpt_delay_100_ms(
	input clk,
	input n_rst,
	input start,
	output stop
);
reg en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) en = 0;
	else if(start) en = 1;
	else if(stop)  en = 0;
end

parameter TICKS_IN_100_MS = (((`CLK_FREQ) / 10) - 1);

assign stop = (ticks == TICKS_IN_100_MS);

reg[22:0] ticks;
always@(posedge clk or negedge en)
begin
	if(en == 0) ticks = 0;
	else        ticks = ticks + 1;
end
endmodule 


module rpt_by_sd_busy_cntr (
	input incr,
	input rst,
	output reg[1:0] cntr
);
always@(posedge incr or posedge rst)
begin
	if(rst) cntr = 0;
	else    cntr = cntr + 1;
end
endmodule
