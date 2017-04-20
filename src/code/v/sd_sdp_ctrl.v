module sd_sdp_ctrl (
	input  clk,
	input  n_rst,
	
	input  sd_s_req,
	input  sd_d_req,
	
	input  rx_err,

	input  sd_d_tx_rdy,
	output sd_d_tx_en,
	
	input  [7:0] sd_d,
	input  sd_d_rdy,
	
	input  sd_has_next_dp,
	input  sd_busy,
	
	input  cd_busy,
	output [7:0] q,
	output q_rdy,
	output msg_end
);

`include "src/code/vh/msg_defs.vh"
`include "src/code/vh/hsi_config.vh"

assign sd_d_tx_en = SENDING_PAYLOAD;

reg rx_err_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		rx_err_reg = 0;
	else if(SDP_TX_START)
		rx_err_reg = rx_err;
end

reg sd_d_req_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		sd_d_req_reg = 0;
	else if(SDP_TX_START)
		sd_d_req_reg = sd_d_req;
end

reg sd_s_req_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		sd_s_req_reg = 0;
	else if(SDP_TX_START)
		sd_s_req_reg = sd_s_req;
end

wire SDP_TX_START = sd_s_req | sd_d_req;

wire CONTROL = (sdc_state == SDC_STATE_CTRL);
wire SENDING_SERVICE_DATA = (sdc_state == SDC_STATE_SENDING_SERVICE_DATA);
wire SENDING_PAYLOAD = (sdc_state == SDC_STATE_SENDING_PAYLOAD);

reg[1:0] sdc_state;
parameter SDC_STATE_CTRL = 0,
			 SDC_STATE_SENDING_SERVICE_DATA = 1,
			 SDC_STATE_SENDING_PAYLOAD = 2;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		sdc_state = SDC_STATE_CTRL;
	else
		begin
			case(sdc_state)
			SDC_STATE_CTRL:
				begin
					if(SDP_TX_START)
						sdc_state = SDC_STATE_SENDING_SERVICE_DATA;
				end
			SDC_STATE_SENDING_SERVICE_DATA:
				begin
					if(SERVICE_DATA_IS_SENT)
						begin
							if(sd_d_req_reg)
								sdc_state = SDC_STATE_SENDING_PAYLOAD;
							else 
								sdc_state = SDC_STATE_CTRL;
						end
					else
						sdc_state = SDC_STATE_SENDING_SERVICE_DATA;
				end
			SDC_STATE_SENDING_PAYLOAD:
				begin
					if(msg_end)
						sdc_state = SDC_STATE_CTRL;
					else
						sdc_state = SDC_STATE_SENDING_PAYLOAD;
				end
			default:
				begin
				
				end
			endcase
		end
end

wire[7:0] STATUS;
assign STATUS[0] = ERROR_IN_MSG;
assign STATUS[1] = SERVICE_REQ;
assign STATUS[2] = SD_BUSY;
assign STATUS[4] = DP_SENDING;	  

wire ERROR_IN_MSG = rx_err_reg,
     SERVICE_REQ  = ~rx_err_reg & ~sd_busy & (sd_s_req_reg ? sd_d_tx_rdy : sd_has_next_dp),
     SD_BUSY      = sd_busy,
     DP_SENDING   = ~rx_err_reg & sd_d_req_reg;

wire SERVICE_DATA_IS_SENT = sd_d_req_reg ? (byte_cntr == 4) : (~cd_busy & (byte_cntr == 4));
reg[10:0] byte_cntr;

wire N_RST_BYTE_CNTR = ~CONTROL;
always@(posedge cd_busy or negedge N_RST_BYTE_CNTR)
begin
	if(N_RST_BYTE_CNTR == 0)
		byte_cntr = 0;
	else 
		byte_cntr = byte_cntr + 1;
end


wire [7:0] MASK_Q_MARKER = (SENDING_SERVICE_DATA & (byte_cntr == 0)) ? 8'hFF : 0,
			  MASK_Q_STATUS = (SENDING_SERVICE_DATA & (byte_cntr == 1)) ? 8'hFF : 0,	
			  MASK_Q_N1     = (SENDING_SERVICE_DATA & (byte_cntr == 2)) ? 8'hFF : 0,
			  MASK_Q_N2     = (SENDING_SERVICE_DATA & (byte_cntr == 3)) ? 8'hFF : 0,
			  MASK_Q_PL     = SENDING_PAYLOAD ? 8'hFF : 0;
			  
assign q = MASK_Q_MARKER & `MARKER_SLAVE  |
			  MASK_Q_STATUS & STATUS |
			  MASK_Q_N1	& (sd_d_req_reg ? (`S_DP_LEN >> 8): 0) |
			  MASK_Q_N2 & (sd_d_req_reg ? `S_DP_LEN : 0) |
			  MASK_Q_PL & sd_d;

assign q_rdy = SENDING_SERVICE_DATA ? (~cd_busy & ~SERVICE_DATA_IS_SENT) : sd_d_rdy;
assign msg_end = sd_d_req_reg ? ((byte_cntr == (`S_DP_LEN + 4)) & ~cd_busy & SENDING_PAYLOAD) : SERVICE_DATA_IS_SENT;


endmodule