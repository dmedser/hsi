module hsi_s_rx_ctrl (
	input clk,
	input clk_en,
	input n_rst,
	input com1,
	input com2,
	output [7:0] q,
	output q_rdy
);

decoder DC (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(clk_en),
	.d(com1),
	.q(q),
	.q_rdy(q_rdy),
	.err(),
	.msg_end()
);

endmodule 