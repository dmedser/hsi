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
	output cd_busy,
	input byte_hold,
	
	input com_src,
	input dat_src,
	
	output [7:0] q,
	output q_rdy,

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
	.cd_busy(cd_busy),
	.byte_hold(byte_hold),
	
	.com_src(com_src),
	.com1(com1),
	.com2(com2)
);

hsi_m_rx_ctrl HSI_M_RX_CTRL (
	.clk(clk),
	.clk_en(DC_CLK_EN),
	.n_rst(n_rst),
	.sdreq_en(sdreq_en),
	.dat_src(dat_src),
	
	.q(q),
	.q_rdy(q_rdy), 
	
	.dat1(dat1),
	.dat2(dat2)
);


endmodule





