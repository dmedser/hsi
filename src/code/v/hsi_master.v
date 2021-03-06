module hsi_master (
	input clk,
	input n_rst,
	
	input en,
	
	input  sdreq_en,
	input  sr_tx_rdy,
	output sr_tx_ack,
	output sr_repeat_req,
	
	input  tm_en,
	input  tm_tx_rdy,
	output tm_tx_ack,
	input  pre_tm,
	
	input btc_en,
	input [39:0] btc,
	
	input  ccw_accepted,
	input  ccw_tx_rdy,
	output ccw_rx_rdy,
	input  [7:0] ccw_byte,
	output ccw_repeat_req,
	
	input base_com,
	input [1:0] com_en,
	output curr_com_src,
	
	input dat_src,
	input [1:0] dat_en,
	
	output [7:0] q,
	output q_rdy,
	output [5:0] rx_errs,
	output rx_frame_end,

	output com1,
	output com2,
	input dat1,
	input dat2
);


assign com1 = com_en[0] ? CSC_COM1 : 1;
assign com2 = com_en[1] ? CSC_COM2 : 1;


m_clk_en_ctrl M_CLK_EN_CTRL(
	.clk(clk),
	.n_rst(n_rst),
	.tx_clk_en(CD_CLK_EN),
	.rx_clk_en(DC_CLK_EN)
);

hsi_m_tx_ctrl HSI_M_TX_CTRL(
	.clk(clk),
	.clk_en(CD_CLK_EN),
	.n_rst(n_rst),
	
	.en(en),
	
	.sdreq_en(sdreq_en),
	.sr_tx_rdy(sr_tx_rdy),
	.sr_tx_ack(sr_tx_ack),
	
	.tm_en(tm_en),
	.tm_tx_rdy(tm_tx_rdy),
	.tm_tx_ack(tm_tx_ack),
	.pre_tm(pre_tm),
	
	.btc_en(btc_en),
	.btc(btc),
	
	.ccw_byte(ccw_byte),
	.ccw_tx_rdy(ccw_tx_rdy),
	.ccw_rx_rdy(ccw_rx_rdy),
	
	.cd_q(CD_Q),
	
	
	.delays_after_cmds_for_reply(DELAYS_AFTER_CMDS_FOR_REPLY),
	.frame_to_reply_end(FRAME_TO_REPLY_END),
	
	.dpr_tx_rdy(DPR_TX_RDY),
	.dpr_tx_ack(DPR_TX_ACK)
);

wire[2:0] DELAYS_AFTER_CMDS_FOR_REPLY;

wire[5:0] RX_ERRS;
assign rx_frame_end = RX_FRAME_END;
assign rx_errs = RX_ERRS;

hsi_m_rx_ctrl HSI_M_RX_CTRL (
	.clk(clk),
	.clk_en(DC_CLK_EN),
	.n_rst(n_rst),
	.dat_src(dat_src),
	
	.q(q),
	.q_rdy(q_rdy), 
	
	.dat1(dat_en[0] ? dat1 : 1),
	.dat2(dat_en[1] ? dat2 : 1),
	
	.rx_frame_end(RX_FRAME_END),
	.rx_start_bit_accepted(RX_START_BIT_ACCEPTED),
	.rx_sd_busy(RX_SD_BUSY),
	.rx_errs(RX_ERRS),
	
	.dpr_repeat_req(DPR_REPEAT_REQ),
	
	.dpr_tx_rdy(DPR_TX_RDY),
	.dpr_tx_ack(DPR_TX_ACK)
);

wire RX_ERR = RX_FRAME_END & ~RX_ERRS[0];

emergency_ctrl EMGC_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.ccw_accepted(ccw_accepted),
	.delays_after_cmds_for_reply(DELAYS_AFTER_CMDS_FOR_REPLY),
	.rx_sd_busy(RX_SD_BUSY),
	.rx_start_bit_accepted(RX_START_BIT_ACCEPTED),
	.rx_frame_end(RX_FRAME_END),
	.rx_err(RX_ERR),
	.repeat_reqs(REPEAT_REQUESTS),
	.switch_com_src_req(SWITCH_COM_SRC_REQUEST),
	.rst_com_src_ctrl(RST_COM_SRC_CTRL)
);

wire[2:0] REPEAT_REQUESTS;
wire SR_REPEAT_REQ  = REPEAT_REQUESTS[0],
     DPR_REPEAT_REQ = REPEAT_REQUESTS[1],
     CCW_REPEAT_REQ = REPEAT_REQUESTS[2];

wire SWITCH_COM_SRC_REQUEST;

assign ccw_repeat_req = CCW_REPEAT_REQ;
assign sr_repeat_req = SR_REPEAT_REQ;

com_src_ctrl COM_SRC_CTRL (
	.clk(clk),
	.n_rst(n_rst & ~RST_COM_SRC_CTRL),
	.switch_com_src_req(SWITCH_COM_SRC_REQUEST),
	.frame_to_reply_end(FRAME_TO_REPLY_END),
   .base_com(base_com),
	.cd_q(CD_Q),
	.curr_com_src(curr_com_src),
	.com1(CSC_COM1),
	.com2(CSC_COM2)
);

wire COM_SRC;
wire CSC_COM1,
	  CSC_COM2;

endmodule


module com_src_ctrl (
	input clk,
	input n_rst,
	input switch_com_src_req,
	input frame_to_reply_end,
   input base_com,
	input cd_q,
	output curr_com_src,
	output com1,
	output com2
);

assign curr_com_src = base_com ^ (switch_com_src_en & flip);

assign com1 = curr_com_src ? 1 : cd_q;
assign com2 = curr_com_src ? cd_q : 1;

reg switch_com_src_en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		switch_com_src_en = 0;
	else if(switch_com_src_req)
		switch_com_src_en = 1;
	else if(frame_to_reply_end)
		switch_com_src_en = 0;
end

reg flip;
always@(posedge switch_com_src_en or negedge n_rst)
begin
	if(n_rst == 0)
		flip = 0;
	else
		flip = ~flip;
end

endmodule





