module hsi_m_rx_ctrl (
	input clk,
	input clk_en,
	input n_rst,

	output [7:0] q,
	output q_rdy,

	input dat_src,
	input dat1,
	input dat2,
	
	output rx_start_bit_accepted,
	output rx_frame_end,
	output [5:0] rx_errs,	
	
	output rx_sd_busy,
	
	input dpr_repeat_req,
	
	output dpr_tx_rdy,
	input  dpr_tx_ack
);

wire DC_D = dat_src ? dat2 : dat1;	

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
	.rx_service_req(RX_SERVICE_REQ),
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

service_req_ctrl SERVICE_REQ_CTRL (
	.clk(clk),
	.n_rst(n_rst), 
	.dpr_repeat_req(dpr_repeat_req),
	.rx_service_req(RX_SERVICE_REQ),
	.dpr_tx_rdy(dpr_tx_rdy),
	.dpr_tx_ack(dpr_tx_ack)
);

endmodule


module service_req_ctrl (
	input clk,
	input n_rst, 
	input rx_service_req,
	input dpr_repeat_req, 
	output reg dpr_tx_rdy,
	input dpr_tx_ack
);
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		dpr_tx_rdy = 0;
	else if(rx_service_req | dpr_repeat_req)
		dpr_tx_rdy = 1;
	else if(dpr_tx_ack)
		dpr_tx_rdy = 0;
end
endmodule




