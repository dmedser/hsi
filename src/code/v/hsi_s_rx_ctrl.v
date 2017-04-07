module hsi_s_rx_ctrl (
	input clk,
	input clk_en,
	input n_rst,
	input com1,
	input com2,
	output [7:0] q,
	output q_rdy,
	output rx_msg_end,
	output [7:0] rx_flg,
	output [5:0] rx_errs
);

`include "src/code/vh/msg_defs.vh"

decoder DC (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(clk_en),
	.d(com1|com2),
	.q(DC_Q),
	.q_rdy(DC_Q_RDY),
	.pb_err(PB_ERR),
	.msg_end(DC_MSG_END)
);

wire[7:0] DC_Q;
assign q_rdy = DC_Q_RDY;
assign q = DC_Q; 
assign rx_msg_end = DC_MSG_END;

err_check ERR_CHECK (
	.clk(clk),
	.n_rst(n_rst),
	.d(DC_Q),
	.d_rdy(DC_Q_RDY),
	.rx_flg(rx_flg),
	.pb_err(PB_ERR),
	.crc(CRC16),
	.crc_update_disable(CRC_UPDATE_DISABLE),
	.crc_rst(CRC_RST),
	.rx_msg_end(DC_MSG_END),
	.rx_errs(rx_errs)
);

wire[15:0] CRC16;
crc16_citt_calc CRC16_CITT_CALC (
	.clk(clk),
	.n_rst(n_rst & ~CRC_RST),
	.d(DC_Q),
	.en(DC_Q_RDY_TRIMMED & ~CRC_UPDATE_DISABLE),
	.crc(CRC16)
); 

signal_trimmer SIGNAL_TRIMMER (
	.clk(clk),
	.s(DC_Q_RDY),
	.trim_s(DC_Q_RDY_TRIMMED)
);
		 
endmodule 
