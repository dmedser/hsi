module ccw_emgc_ctrl (
	input clk,
	input n_rst, 
	input ccw_accepted,
	input sd_busy,
	input no_reply_or_err,
	output ccw_repeat_req,
	output ccw_toggle_com_src_req
);

`include "src/code/vh/hsi_config.vh"

wire CCW_REPEAT_DELAY_START = sd_busy & (CCW_REPEAT_REQ_CNTR < 3);

ccw_repeat_delay_100_ms CCW_REPEAT_DELAY_100_MS (
	.clk(clk),
	.n_rst(n_rst),
	.start(CCW_REPEAT_DELAY_START),
	.delay_is_over(ccw_repeat_req)
);

ccw_repeat_req_counter CCW_REPEAT_REQ_COUNTER (
	.ccw_repeat_delay_start(CCW_REPEAT_DELAY_START),
	.rst(ccw_accepted),
	.ccw_repeat_req_cntr(CCW_REPEAT_REQ_CNTR)
);
wire[1:0] CCW_REPEAT_REQ_CNTR; 

endmodule

module ccw_repeat_delay_100_ms(
	input clk,
	input n_rst,
	input start,
	output delay_is_over
);
reg delay_en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		delay_en = 0;
	else if(start)
		delay_en = 1;
	else if(delay_is_over)
		delay_en = 0;
end
parameter TICKS_IN_100_MS = (((`CLK_FREQ) / 10) - 1);
assign delay_is_over = (ticks == TICKS_IN_100_MS);
reg[22:0] ticks;
always@(posedge clk or negedge delay_en)
begin
	if(delay_en == 0)
		ticks = 0;
	else 
		ticks = ticks + 1;
end
endmodule 


module ccw_repeat_req_counter (
	input ccw_repeat_delay_start,
	input rst,
	output reg[1:0] ccw_repeat_req_cntr
);
always@(posedge ccw_repeat_delay_start or posedge rst)
begin
	if(rst)
		ccw_repeat_req_cntr = 0;
	else 
		ccw_repeat_req_cntr = ccw_repeat_req_cntr + 1;
end
endmodule
