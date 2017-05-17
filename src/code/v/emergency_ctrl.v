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
	output switch_com_src_req,
	output rst_com_src_ctrl
);

reply_timeout_ctrl REPLY_TIMEOUT_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.rx_start_bit_accepted(rx_start_bit_accepted),
	.rx_frame_end(rx_frame_end),
	.delays_after_cmds_for_reply(delays_after_cmds_for_reply),
	.reply_timeout(REPLY_TIMEOUT),
	.replies_reception(REPLIES_RECEPTION)
);

wire[2:0] REPLY_TIMEOUT;
wire SR_REPLY_TIMEOUT  = REPLY_TIMEOUT[0],
	  DPR_REPLY_TIMEOUT = REPLY_TIMEOUT[1],
	  CCW_REPLY_TIMEOUT = REPLY_TIMEOUT[2];

wire[2:0] REPLIES_RECEPTION;
wire SR_REPLY_RECEPTION  = REPLIES_RECEPTION[0],
	  DPR_REPLY_RECEPTION = REPLIES_RECEPTION[1],
     CCW_REPLY_RECEPTION = REPLIES_RECEPTION[2];

assign repeat_reqs[0] = SR_REPEAT_REQ;
assign repeat_reqs[1] = DPR_REPEAT_REQ;
assign repeat_reqs[2] = CCW_REPEAT_REQ;

assign rst_com_src_ctrl = SR_RST_COM_SRC_CTRL | DPR_RST_COM_SRC_CTRL | CCW_RST_COM_SRC_CTRL;
assign switch_com_src_req = SR_SWITCH_COM_SRC_REQ | DPR_SWITCH_COM_SRC_REQ | CCW_SWITCH_COM_SRC_REQ;



wire SR_SWITCH_COM_SRC_REQ, 
	  DPR_SWITCH_COM_SRC_REQ,
	  CCW_SWITCH_COM_SRC_REQ; 

ccw_emgc_ctrl CCW_EMGC_CTRL (
	.clk(clk),
	.n_rst(n_rst), 
	.ccw_accepted(ccw_accepted),
	.sd_busy(CCW_REPLY_RECEPTION & rx_frame_end & rx_sd_busy & ~rx_err),
	.no_reply_or_err(CCW_NO_REPLY_OR_ERR),
	.repeat_req(CCW_REPEAT_REQ),
	.switch_com_src_req(CCW_SWITCH_COM_SRC_REQ),
	.rst_com_src_ctrl(CCW_RST_COM_SRC_CTRL)
);


delay_100_us DELAY_100_US (
	.clk(clk),
	.n_rst(n_rst),
	.start_src(DELAY_100_US_START_SRC),
	.stop_dst(NO_REPLY_OR_ERR_DST)
);

wire[2:0] DELAY_100_US_START_SRC;
wire SR_DELAY_100_US_START  = (SR_REPLY_RECEPTION  & rx_frame_end & rx_err) | SR_REPLY_TIMEOUT,
	  DPR_DELAY_100_US_START = (DPR_REPLY_RECEPTION & rx_frame_end & rx_err) | DPR_REPLY_TIMEOUT,
	  CCW_DELAY_100_US_START = (CCW_REPLY_RECEPTION & rx_frame_end & rx_err) | CCW_REPLY_TIMEOUT;

assign DELAY_100_US_START_SRC[0] = SR_DELAY_100_US_START;
assign DELAY_100_US_START_SRC[1] = DPR_DELAY_100_US_START;
assign DELAY_100_US_START_SRC[2] = CCW_DELAY_100_US_START;	  
	  

wire[2:0] NO_REPLY_OR_ERR_DST;
wire SR_NO_REPLY_OR_ERR  = NO_REPLY_OR_ERR_DST[0],
	  DPR_NO_REPLY_OR_ERR = NO_REPLY_OR_ERR_DST[1],
     CCW_NO_REPLY_OR_ERR = NO_REPLY_OR_ERR_DST[2] & (CCW_NRE_CNTR < 3);

 	
ccw_no_reply_or_err_cntr CCW_NO_REPLY_OR_ERR_COUNTER (
	.clk(clk),
	.n_rst(n_rst & ~ccw_accepted),
	.no_reply_or_err(CCW_NO_REPLY_OR_ERR),
	.cntr(CCW_NRE_CNTR)
);
wire[2:0] CCW_NRE_CNTR;	  

sr_emgc_ctrl SR_EMGC_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.no_reply_or_err(SR_NO_REPLY_OR_ERR),
	.repeat_req(SR_REPEAT_REQ),
	.switch_com_src_req(SR_SWITCH_COM_SRC_REQ),
	.rst_com_src_ctrl(SR_RST_COM_SRC_CTRL)
);

wire SR_REPEAT_REQ,
	  SR_RST_COM_SRC_CTRL;


dpr_emgc_ctrl DPR_EMGC_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.no_reply_or_err(DPR_NO_REPLY_OR_ERR),
	.repeat_req(DPR_REPEAT_REQ),
	.switch_com_src_req(DPR_SWITCH_COM_SRC_REQ),
	.rst_com_src_ctrl(DPR_RST_COM_SRC_CTRL)
);
	  
wire DPR_REPEAT_REQ,	  
	  DPR_RST_COM_SRC_CTRL;
	  
endmodule 


module reply_timeout_ctrl (
	input clk,
	input n_rst,
	input [2:0] delays_after_cmds_for_reply,
	input rx_start_bit_accepted,
	input rx_frame_end,
	output [2:0] reply_timeout,
	output reg[2:0] replies_reception
);

assign reply_timeout[0] = tick_after_sr_delay  & ~reply_sr_reg;
assign reply_timeout[1] = tick_after_dpr_delay & ~reply_dpr_reg;
assign reply_timeout[2] = tick_after_ccw_delay & ~reply_ccw_reg;

wire TICK_AFTER_ANY_DELAY = tick_after_sr_delay | tick_after_dpr_delay | tick_after_ccw_delay;

reg reply_sr_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		reply_sr_reg = 0;
	else if (replies_reception[0])
		reply_sr_reg = 1;
	else if(TICK_AFTER_ANY_DELAY)
		reply_sr_reg = 0;
end



reg reply_dpr_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		reply_dpr_reg = 0;
	else if (replies_reception[1])
		reply_dpr_reg = 1;
	else if(TICK_AFTER_ANY_DELAY)
		reply_dpr_reg = 0;
end



reg reply_ccw_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		reply_ccw_reg = 0;
	else if (replies_reception[2])
		reply_ccw_reg = 1;
	else if(TICK_AFTER_ANY_DELAY)
		reply_ccw_reg = 0;
end


reg tick_after_frame_end;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tick_after_frame_end = 0;
	else if(rx_frame_end)
		tick_after_frame_end = 1;
	else 
		tick_after_frame_end = 0;
end

wire DELAY_SR  = delays_after_cmds_for_reply[0],
	  DELAY_DPR = delays_after_cmds_for_reply[1],
	  DELAY_CCW = delays_after_cmds_for_reply[2]; 

wire DELAY_AFTER_CMD_FOR_REPLY = DELAY_SR | DELAY_DPR | DELAY_CCW;
								
wire tick_after_sr_delay = ~DELAY_SR & sync_delay_sr;
reg sync_delay_sr;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)  	sync_delay_sr = 0;
	else if(DELAY_SR) sync_delay_sr = 1;
	else 					sync_delay_sr = 0;
end

wire tick_after_dpr_delay = ~DELAY_DPR & sync_delay_dpr;
reg sync_delay_dpr;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)		 sync_delay_dpr = 0;
	else if(DELAY_DPR) sync_delay_dpr = 1;
	else 					 sync_delay_dpr = 0;
end

wire tick_after_ccw_delay = ~DELAY_CCW & sync_delay_ccw;
reg sync_delay_ccw;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)	 	 sync_delay_ccw = 0;
	else if(DELAY_CCW) sync_delay_ccw = 1;
	else 					 sync_delay_ccw = 0;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		replies_reception = 0;
	else if(tick_after_frame_end)
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
	output [2:0] stop_dst
);

wire START = start_src[0] | start_src[1] | start_src[2];

wire SR_DELAY_START  = start_src[0],
     DPR_DELAY_START = start_src[1],
     CCW_DELAY_START = start_src[2];

reg sr_delay;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)          sr_delay = 0;
	else if(SR_DELAY_START) sr_delay = 1;
	else if(en == 0)        sr_delay = 0;
end

reg dpr_delay;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)           dpr_delay = 0;
	else if(DPR_DELAY_START) dpr_delay = 1;
	else if(en == 0)         dpr_delay = 0;
end

reg ccw_delay;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)           ccw_delay = 0;	
	else if(CCW_DELAY_START) ccw_delay = 1;
	else if(en == 0)         ccw_delay = 0;
end

assign stop_dst[0] = STOP & sr_delay;
assign stop_dst[1] = STOP & dpr_delay;
assign stop_dst[2] = STOP & ccw_delay;

reg en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) en = 0;
	else if(START) en = 1;
	else if(STOP)  en = 0;
end

parameter TICKS_IN_100_US = (((`CLK_FREQ) / 10000) - 1);
wire STOP = (ticks == TICKS_IN_100_US);

reg[12:0] ticks;
always@(posedge clk or negedge en)
begin
	if(en == 0) ticks = 0;
	else        ticks = ticks + 1;
end
endmodule  


module ccw_no_reply_or_err_cntr (
	input  clk,
	input  n_rst,
	input  no_reply_or_err,
	output reg[2:0] cntr
);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)           cntr = 0;
	else if(no_reply_or_err) cntr = cntr + 1;
end
endmodule 


module sr_emgc_ctrl (
	input  clk,
	input  n_rst,
	input  no_reply_or_err,
	output repeat_req,
	output switch_com_src_req,
	output rst_com_src_ctrl
);

assign repeat_req = no_reply_or_err & ~rpt_disable;
reg rpt_disable;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) rpt_disable = 0;
	else if(no_reply_or_err)
		rpt_disable = ~rpt_disable;
end

reg tmp;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) tmp = 0;
	else if(rpt_disable) tmp = 1;
	else tmp = 0;
end

wire tick_after_rpt_disable_off = tmp & ~rpt_disable;
assign switch_com_src_req = repeat_req;
assign rst_com_src_ctrl = tick_after_rpt_disable_off;
endmodule



module dpr_emgc_ctrl (
	input  clk,
	input  n_rst,
	input  no_reply_or_err,
	output repeat_req,
	output switch_com_src_req,
	output rst_com_src_ctrl 
);


assign repeat_req = no_reply_or_err & ~rpt_disable;
reg rpt_disable;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) rpt_disable = 0;
	else if(no_reply_or_err)
		rpt_disable = ~rpt_disable;
end

reg tmp;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) tmp = 0;
	else if(rpt_disable) tmp = 1;
	else tmp = 0;
end

wire tick_after_rpt_disable_off = tmp & ~rpt_disable;
assign switch_com_src_req = repeat_req;
assign rst_com_src_ctrl = tick_after_rpt_disable_off;
endmodule

