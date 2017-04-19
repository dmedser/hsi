module hsi_m_rx_ctrl (
	input clk,
	input clk_en,
	input n_rst,
	input sdreq_en,
	input dat_src,
	
	output [7:0] q,
	output q_rdy,

	input dat1,
	input dat2,
	
	output rx_frame_end,
	output rx_start_bit_accepted,
	
	output rx_service_req,
	output rx_sd_busy,
	
	output [5:0] rx_errs
);

wire DC_D = dat_src ? dat1 : dat2;	

decoder DC (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(clk_en),
	.d(DC_D),
	.q(DC_Q),
	.q_rdy(DC_Q_RDY),
	.pb_err(PB_ERR),
	.frame_end(DC_FRAME_END),
	.start_bit_accepted(rx_start_bit_accepted)
);

wire[7:0] DC_Q;
assign q_rdy = DC_Q_RDY;
assign q = DC_Q; 
assign rx_frame_end = DC_FRAME_END;

m_err_check ERR_CHECK (
	.clk(clk),
	.n_rst(n_rst),
	.d(DC_Q),
	.d_rdy(DC_Q_RDY),
	.rx_service_req(rx_service_req),
	.rx_sd_busy(rx_sd_busy),
	.pb_err(PB_ERR),
	.crc(CRC16),
	.crc_update_disable(CRC_UPDATE_DISABLE),
	.crc_rst(CRC_RST),
	.rx_frame_end(DC_FRAME_END),
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




