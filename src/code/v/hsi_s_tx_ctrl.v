module hsi_s_tx_ctrl (
	input clk,
	input clk_en,
	input n_rst,
	
	input sd_busy,
	
	input  sd_d_tx_rdy,
	output sd_d_tx_en,
	
	input  [7:0] sd_d,
	input  sd_d_rdy,
	output sd_d_sending,
	input  sd_has_next_dp,
	
	output dat1,
	output dat2,
	
	input [7:0] rx_flag,

	input rx_frame_end,
	input rx_err
);
assign dat1 = CD_Q;
assign dat2 = CD_Q;
assign sd_d_sending = CD_BUSY & sd_d_tx_en & sd_d_tx_rdy;

wire[7:0] D_SDP,
			 D_CRC;

wire D_RDY_SDP,
     D_RDY_CRC;			 

wire MSG_END_SDP,
	  MSG_END_CRC;
	  
wire[15:0] CRC16;	  
wire[7:0] TX_D;

coder CD (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(clk_en),
	.d(TX_D),
	.d_rdy(TX_D_RDY),
	.busy(CD_BUSY),
	.q(CD_Q)
);


sd_sdp_ctrl SD_SDP_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	
	.sd_s_req(SD_S_REQ),
	.sd_d_req(SD_D_REQ),
	.rx_err(rx_err),
	
	.sd_d_tx_rdy(sd_d_tx_rdy),
	.sd_d_tx_en(sd_d_tx_en),
	
	.sd_d(sd_d),
	.sd_d_rdy(sd_d_rdy),
	
	.sd_has_next_dp(sd_has_next_dp),
	.sd_busy(sd_busy),
	
	.cd_busy(CD_BUSY),
	.q(D_SDP),
	.q_rdy(D_RDY_SDP),
	.msg_end(MSG_END_SDP)
);

signal_trimmer SIGNAL_TRIMMER (
	.clk(clk),
	.s(TX_D_RDY),
	.trim_s(TX_D_RDY_TRIMMED)
);

crc_sender CRC_SENDER  (
	.clk(clk),
	.crc_tx_en(SENDING_CRC),
	.crc(WRONG_CRC),
	.crc_rdy(MSG_END_SDP),
	.cd_busy(CD_BUSY),
	.q_rdy(D_RDY_CRC),
	.q(D_CRC),
	.msg_end(MSG_END_CRC)
);

/////////////////////////////////////
wire[15:0] WRONG_CRC = sd_d_req_reg ? (CRC16 & 16'h0F) : CRC16; 
////////////////////////////////////

crc16_citt_calc CRC16_CITT_CALC (
	.clk(clk),
	.n_rst(n_rst & ~(SENDING_CRC)),
	.d(TX_D),
	.en(TX_D_RDY_TRIMMED),
	.crc(CRC16)
);

s_connector CONNECTOR (
	.tx_state(TX_STATE_CONNECTOR),
	.d_rdy_src(D_RDY_SRC),
	.d_rdy_dst(TX_D_RDY),
	.d_src(D_SRC),
	.d_dst(TX_D)
);

wire[1:0] TX_STATE_CONNECTOR;
assign TX_STATE_CONNECTOR[0] = SENDING_SDP;
assign TX_STATE_CONNECTOR[1] = SENDING_CRC;

wire[1:0] D_RDY_SRC;
assign D_RDY_SRC[0] = D_RDY_SDP;
assign D_RDY_SRC[1] = D_RDY_CRC;

wire[15:0] D_SRC;
assign D_SRC[7:0]  = D_SDP;
assign D_SRC[15:8] = D_CRC;


wire SENDING_SDP = (tx_state == TX_STATE_SENDING_SDP);
wire SENDING_CRC = (tx_state == TX_STATE_SENDING_CRC);

wire SD_S_REQ = (rx_frame_end & ((rx_flag == `FLAG_CONTROL_COMMAND_WORD) | (rx_flag == `FLAG_STATUS_REQUEST))) ;
wire SD_D_REQ = (rx_frame_end & (rx_flag == `FLAG_DATA_PACKET_REQUEST));

/////////////////////////////////////////////
reg sd_d_req_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		sd_d_req_reg = 0;
	else if(rx_frame_end)
		sd_d_req_reg = (rx_flag == `FLAG_DATA_PACKET_REQUEST) ? 1 : 0;
end
///////////////////////////////////////////////////

wire SDP_TX_START = SD_S_REQ | SD_D_REQ;

reg[1:0] tx_state;
parameter TX_STATE_CTRL = 0,
			 TX_STATE_SENDING_SDP = 1,
			 TX_STATE_SENDING_CRC = 2;
	
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tx_state = TX_STATE_CTRL;
	else
		begin
			case(tx_state)
			TX_STATE_CTRL:
				begin
					if(SDP_TX_START)
						tx_state = TX_STATE_SENDING_SDP;
					else 
						tx_state = TX_STATE_CTRL;
				end
			TX_STATE_SENDING_SDP:
				begin
					if(MSG_END_SDP)	
						tx_state = TX_STATE_SENDING_CRC;
					else 
						tx_state = TX_STATE_SENDING_SDP;
				end
			TX_STATE_SENDING_CRC:
				begin
					if(MSG_END_CRC)
						tx_state = TX_STATE_CTRL;
					else 
						tx_state = TX_STATE_SENDING_CRC;
				end
			default:
				begin
				
				end
			endcase			
		end
end

endmodule
