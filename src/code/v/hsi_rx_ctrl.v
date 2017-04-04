module hsi_rx_ctrl (
	input clk,
	input clk_en,
	input n_rst,
	input sdreq_en,
	input dat_src,
	
	output reg [7:0] q,

	input dat1,
	input dat2
);

wire DC_D = dat_src ? dat1 : dat2;	

decoder DC (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(clk_en),
	.d(DC_D),
	.q(),
	.q_rdy(),
	.err(),
	.msg_end()
);

endmodule