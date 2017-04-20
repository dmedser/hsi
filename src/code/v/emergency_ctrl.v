module emergency_ctrl (
	input clk,
	input n_rst,
	input ccw_accepted,
	input [2:0] delays_after_cmds_for_reply,
	input rx_sd_busy,
	input rx_start_bit_accepted,
	input rx_frame_end,
	input rx_err,
	output [2:0] repeat_reqs,
	output [2:0] toggle_com_src_reqs
);

no_reply_ctrl NO_REPLY_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.rx_start_bit_accepted(rx_start_bit_accepted),
	.rx_frame_end(rx_frame_end),
	.delays_after_cmds_for_reply(delays_after_cmds_for_reply),
	.no_reply(NO_REPLY),
	.replies_reception(REPLIES_RECEPTION)
);

wire[2:0] NO_REPLY;
wire SR_NO_REPLY  = NO_REPLY[0],
	  DPR_NO_REPLY = NO_REPLY[1],
	  CCW_NO_REPLY = NO_REPLY[2];

wire[2:0] REPLIES_RECEPTION;
wire SR_REPLY_RECEPTION  = REPLIES_RECEPTION[0],
	  DPR_REPLY_RECEPTION = REPLIES_RECEPTION[1],
     CCW_REPLY_RECEPTION = REPLIES_RECEPTION[2];


assign repeat_reqs[2] = CCW_REPEAT_REQ;//REPEAT_REQUESTS;

assign toggle_com_src_reqs = TOGGLE_COM_SRC_REQUESTS;

/*
wire[2:0] REPEAT_REQUESTS;

wire SR_REPEAT_REQ  = REPEAT_REQUESTS[0],
     DPR_REPEAT_REQ = REPEAT_REQUESTS[1],
     CCW_REPEAT_REQ = REPEAT_REQUESTS[2];
*/


wire[2:0] TOGGLE_COM_SRC_REQUESTS;
wire SR_TOGGLE_COM_SRC_REQ  = TOGGLE_COM_SRC_REQUESTS[0], 
	  DPR_TOGGLE_COM_SRC_REQ = TOGGLE_COM_SRC_REQUESTS[1],
	  CCW_TOGGLE_COM_SRC_REQ = TOGGLE_COM_SRC_REQUESTS[2]; 


ccw_emgc_ctrl CCW_EMGC_CTRL (
	.clk(clk),
	.n_rst(n_rst), 
	.ccw_accepted(ccw_accepted),
	.sd_busy(CCW_REPLY_RECEPTION & rx_frame_end & rx_sd_busy & ~rx_err),
	.no_reply_or_err(CCW_DELAY_100_US_IS_OVER),
	.ccw_repeat_req(CCW_REPEAT_REQ),
	.ccw_toggle_com_src_req(CCW_TOGGLE_COM_SRC_REQ)
);


delay_100_us DELAY_100_US (
	.clk(clk),
	.n_rst(n_rst),
	.start_src(DELAY_100_US_START_SRC),
	.delay_is_over_dst(DELAY_100_US_IS_OVER_DST)
);

wire[2:0] DELAY_100_US_START_SRC;
wire SR_DELAY_100_US_START  = (SR_REPLY_RECEPTION & rx_frame_end & rx_err) | SR_NO_REPLY,
	  DPR_DELAY_100_US_START = (DPR_REPLY_RECEPTION & rx_frame_end & rx_err) | DPR_NO_REPLY,
	  CCW_DELAY_100_US_START = (CCW_REPLY_RECEPTION & rx_frame_end & rx_err) | CCW_NO_REPLY;

assign DELAY_100_US_START_SRC[0] = SR_DELAY_100_US_START;
assign DELAY_100_US_START_SRC[1] = DPR_DELAY_100_US_START;
assign DELAY_100_US_START_SRC[2] = CCW_DELAY_100_US_START;	  
	  

wire[2:0] DELAY_100_US_IS_OVER_DST;
wire SR_DELAY_100_US_IS_OVER  = DELAY_100_US_IS_OVER_DST[0],
	  DPR_DELAY_100_US_IS_OVER = DELAY_100_US_IS_OVER_DST[1],
     CCW_DELAY_100_US_IS_OVER = DELAY_100_US_IS_OVER_DST[2];

endmodule 


module no_reply_ctrl (
	input clk,
	input n_rst,
	input [2:0] delays_after_cmds_for_reply,
	input rx_start_bit_accepted,
	input rx_frame_end,
	output [2:0] no_reply,
	output reg[2:0] replies_reception
);

assign no_reply[0] = tick_after_sr_delay  & ~replies_reception[0];
assign no_reply[1] = tick_after_dpr_delay & ~replies_reception[1];
assign no_reply[2] = tick_after_ccw_delay & ~replies_reception[2];

wire DELAY_SR  = delays_after_cmds_for_reply[0],
	  DELAY_DPR = delays_after_cmds_for_reply[1],
	  DELAY_CCW = delays_after_cmds_for_reply[2]; 

wire DELAY_AFTER_CMD_FOR_REPLY = DELAY_SR | DELAY_DPR | DELAY_CCW;
								
wire tick_after_sr_delay = ~DELAY_SR & sync_delay_sr;
reg sync_delay_sr;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)	sync_delay_sr = 0;
	else if(DELAY_SR) sync_delay_sr = 1;
	else sync_delay_sr = 0;
end

wire tick_after_dpr_delay = ~DELAY_DPR & sync_delay_dpr;
reg sync_delay_dpr;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)	sync_delay_dpr = 0;
	else if(DELAY_DPR) sync_delay_dpr = 1;
	else sync_delay_dpr = 0;
end

wire tick_after_ccw_delay = ~DELAY_CCW & sync_delay_ccw;
reg sync_delay_ccw;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)	sync_delay_ccw = 0;
	else if(DELAY_CCW) sync_delay_ccw = 1;
	else sync_delay_ccw = 0;
end


reg sync_rx_frame_end;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)	sync_rx_frame_end = 0;
	else if(rx_frame_end) sync_rx_frame_end = 1;
	else sync_rx_frame_end = 0;
end

wire tick_after_rx_frame_end = ~rx_frame_end & sync_rx_frame_end;

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		replies_reception = 0;
	else if(tick_after_rx_frame_end)
		replies_reception = 0;
	else if(DELAY_AFTER_CMD_FOR_REPLY)
		begin
			if(rx_start_bit_accepted)
				replies_reception = delays_after_cmds_for_reply;
		end
end
endmodule


module delay_100_us (
	input clk,
	input n_rst,
	input  [2:0] start_src,
	output [2:0] delay_is_over_dst
);

wire START = start_src[0] | start_src[1] | start_src[2];

wire SR_DELAY_START  = start_src[0],
     DPR_DELAY_START = start_src[1],
     CCW_DELAY_START = start_src[2];

reg sr_delay;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) sr_delay = 0;
	else if(SR_DELAY_START) sr_delay = 1;
	else if(delay_en == 0) sr_delay = 0;
end

reg dpr_delay;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) dpr_delay = 0;
	else if(DPR_DELAY_START) dpr_delay = 1;
	else if(delay_en == 0) dpr_delay = 0;
end

reg ccw_delay;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) ccw_delay = 0;
	else if(CCW_DELAY_START) ccw_delay = 1;
	else if(delay_en == 0) ccw_delay = 0;
end

assign delay_is_over_dst[0] = delay_is_over & sr_delay;
assign delay_is_over_dst[1] = delay_is_over & dpr_delay;
assign delay_is_over_dst[2] = delay_is_over & ccw_delay;

reg delay_en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		delay_en = 0;
	else if(START)
		delay_en = 1;
	else if(delay_is_over)
		delay_en = 0;
end

parameter TICKS_IN_100_US = (((`CLK_FREQ) / 10000) - 1);
wire delay_is_over = (ticks == TICKS_IN_100_US);

reg[12:0] ticks;
always@(posedge clk or negedge delay_en)
begin
	if(delay_en == 0)
		ticks = 0;
	else 
		ticks = ticks + 1;
end
endmodule  


