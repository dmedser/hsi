module hsi_slave (
	input  clk,
	input  n_rst,
	
	input  sd_busy,
	input  usb_err_in_msg,
	
	
	input  sd_d_tx_rdy,
	output sd_d_tx_en,
	
	input  [7:0] sd_d,
	input  sd_d_rdy,
	output sd_d_sending,
	input  sd_has_next_dp,
	
	input  com1,
	input  com2,
	
	output dat1,
	output dat2,
	
	output [7:0] q,
	output q_rdy,
	output rx_frame_end,
	output [5:0] rx_errs
);

s_clk_en_ctrl S_CLK_EN_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.tx_clk_en(CD_CLK_EN),
	.rx_clk_en(DC_CLK_EN)
);

hsi_s_rx_ctrl HSI_S_RX_CTRL (
	.clk(clk),
	.clk_en(DC_CLK_EN),
	.n_rst(n_rst),
	
	.com1(com1),
	.com2(com2),
	
	.q(q),
	.q_rdy(q_rdy),
	
	.rx_frame_end(RX_FRAME_END),
	.rx_flag(RX_FLAG),
	.rx_errs(RX_ERRS)
);

wire[5:0] RX_ERRS;
wire [7:0] RX_FLAG;
assign rx_frame_end = RX_FRAME_END;
assign rx_errs = RX_ERRS;


hsi_s_tx_ctrl HSI_S_TX_CTRL (
	.clk(clk),
	.clk_en(CD_CLK_EN),
	.n_rst(n_rst),
	
	.sd_busy(sd_busy),
	.usb_err_in_msg(usb_err_in_msg),
	

	.sd_d_tx_rdy(sd_d_tx_rdy),
	.sd_d_tx_en(sd_d_tx_en),

	.sd_d(sd_d),
	.sd_d_rdy(sd_d_rdy),
	.sd_d_sending(sd_d_sending),
	.sd_has_next_dp(sd_has_next_dp),
	
	.dat1(dat1),
	.dat2(dat2),
	
	.rx_frame_end(RX_FRAME_END),
	.rx_err(RX_FRAME_END & ~RX_ERRS[0]),
	.rx_flag(RX_FLAG)
);


	

endmodule 