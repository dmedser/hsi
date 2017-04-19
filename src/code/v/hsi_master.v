module hsi_master (
	input clk,
	input n_rst,
	
	input sdreq_en,
	input sr_tx_rdy,
	output sr_tx_ack,
	
	input tm_tx_en,
	input tm_tx_rdy,
	output tm_tx_ack,
	input pre_tm,
	
	input btc_en,
	input [39:0] btc,
	
	input [7:0] ccw_d,
	input ccw_tx_rdy,
	output ccw_tx_en,
	output ccw_d_sending,
	input ccw_d_rdy,
	output ccw_repeat_req,
	
	input com_src,
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
	.ccw_repeat_req(ccw_repeat_req),
	
	.com_src(com_src),
	.com1(com1),
	.com2(com2),
	
	.rx_frame_end(RX_FRAME_END),
	.rx_start_bit_accepted(RX_START_BIT_ACCEPTED),
	.rx_err(RX_FRAME_END & ~RX_ERRS[0]),
	.rx_service_req(RX_SERVICE_REQ),
	.rx_sd_busy(RX_SD_BUSY)
);

wire[5:0] RX_ERRS;
assign rx_frame_end = RX_FRAME_END;
assign rx_errs = RX_ERRS;

hsi_m_rx_ctrl HSI_M_RX_CTRL (
	.clk(clk),
	.clk_en(DC_CLK_EN),
	.n_rst(n_rst),
	.sdreq_en(sdreq_en),
	.dat_src(dat_src),
	
	.q(q),
	.q_rdy(q_rdy), 
	
	.dat1(dat1),
	.dat2(dat2),
	
	.rx_frame_end(RX_FRAME_END),
	.rx_start_bit_accepted(RX_START_BIT_ACCEPTED),
	.rx_service_req(RX_SERVICE_REQ),
	.rx_sd_busy(RX_SD_BUSY),
	.rx_errs(RX_ERRS)
);


endmodule





