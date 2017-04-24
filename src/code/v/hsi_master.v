module hsi_master (
	input clk,
	input n_rst,
	
	input sdreq_en,
	input sr_tx_rdy,
	output sr_tx_ack,
	output sr_repeat_req,
	
	input tm_tx_en,
	input tm_tx_rdy,
	output tm_tx_ack,
	input pre_tm,
	
	input btc_en,
	input [39:0] btc,
	
	input ccw_accepted,
	input [7:0] ccw_d,
	input ccw_tx_rdy,
	output ccw_tx_en,
	output ccw_d_sending,
	input ccw_d_rdy,
	output ccw_repeat_req,
	
	input base_com,
	input dat_src,
	
	output [7:0] q,
	output q_rdy,
	output [5:0] rx_errs,
	output rx_frame_end,

	output com1,
	output com2,
	input dat1,
	input dat2
);

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
	
	.sdreq_en(sdreq_en),
	.sr_tx_rdy(sr_tx_rdy),
	.sr_tx_ack(sr_tx_ack),
	
	.tm_tx_en(tm_tx_en),
	.tm_tx_rdy(tm_tx_rdy),
	.tm_tx_ack(tm_tx_ack),
	.pre_tm(pre_tm),
	
	.btc_en(btc_en),
	.btc(btc),
	
	.ccw_d(ccw_d),
	.ccw_tx_rdy(ccw_tx_rdy),
	.ccw_tx_en(ccw_tx_en),
	.ccw_d_sending(ccw_d_sending),
	.ccw_d_rdy(ccw_d_rdy),
	
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
	
	.dat1(dat1),
	.dat2(dat2),
	
	.rx_frame_end(RX_FRAME_END),
	.rx_start_bit_accepted(RX_START_BIT_ACCEPTED),
	.rx_sd_busy(RX_SD_BUSY),
	.rx_errs(RX_ERRS),
	
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
	.switch_com_src_req(SWITCH_COM_SRC_REQUEST)
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
	.n_rst(n_rst & ~ccw_accepted),
	.switch_com_src_req(SWITCH_COM_SRC_REQUEST),
	.frame_to_reply_end(FRAME_TO_REPLY_END),
   .base_com(base_com),
	.cd_q(CD_Q),
	.com1(com1),
	.com2(com2)
);

endmodule


module com_src_ctrl (
	input clk,
	input n_rst,
	input switch_com_src_req,
	input frame_to_reply_end,
   input base_com,
	input cd_q,
	output com1,
	output com2
);

assign com1 = (base_com ^ (switch_com_src_en & flip)) ? 1 : cd_q;
assign com2 = (base_com ^ (switch_com_src_en & flip)) ? cd_q : 1;

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





