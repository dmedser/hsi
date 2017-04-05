module hsi_slave (
	input clk,
	input n_rst,
	
	input sd_busy,
	input sr,
	
	input com1,
	input com2,
	
	output dat1,
	output dat2,
	
	output [7:0] q,
	output q_rdy
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
	.q_rdy(q_rdy)
);

hsi_s_tx_ctrl HSI_S_TX_CTRL (
	.clk(clk),
	.clk_en(CD_CLK_EN),
	.n_rst(n_rst),
	.sd_busy(sd_busy),
	.sr(sr),
	.dat1(dat1),
	.dat2(dat2)
);

endmodule 