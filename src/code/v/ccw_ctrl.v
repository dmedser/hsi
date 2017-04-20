module ccw_ctrl (
	input clk,
	input n_rst,
	input [7:0] ccw_d,
	input tx_rdy,
	output tx_en,
	input cd_busy,
	input ccw_d_rdy,
	output [7:0] q,
	output q_rdy,
	output msg_end
);

`include "src/code/vh/msg_defs.vh"

assign tx_en = SENDING_PAYLOAD;

wire CONTROL = (ccwc_state == CCWC_STATE_CTRL);
wire SENDING_SERVICE_DATA = (ccwc_state == CCWC_STATE_SENDING_SERVICE_DATA);
wire SENDING_PAYLOAD = (ccwc_state == CCWC_STATE_SENDING_PAYLOAD);

reg[1:0] ccwc_state;
parameter CCWC_STATE_CTRL = 0,
			 CCWC_STATE_SENDING_SERVICE_DATA = 1,
			 CCWC_STATE_SENDING_PAYLOAD = 2;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccwc_state = CCWC_STATE_CTRL;
	else
		begin
			case(ccwc_state)
			CCWC_STATE_CTRL:
				begin
					if(tx_rdy)
						ccwc_state = CCWC_STATE_SENDING_SERVICE_DATA;
				end
			CCWC_STATE_SENDING_SERVICE_DATA:
				begin
					if(SERVICE_DATA_IS_SENT)
						ccwc_state = CCWC_STATE_SENDING_PAYLOAD;
					else
						ccwc_state = CCWC_STATE_SENDING_SERVICE_DATA;
				end
			CCWC_STATE_SENDING_PAYLOAD:
				begin
					if(msg_end)
						ccwc_state = CCWC_STATE_CTRL;
					else
						ccwc_state = CCWC_STATE_SENDING_PAYLOAD;
				end
			default:
				begin
				
				end
			endcase
		end
end

wire SERVICE_DATA_IS_SENT = ~cd_busy & (byte_cntr == 3);

reg[2:0] byte_cntr;
always@(posedge cd_busy or negedge SENDING_SERVICE_DATA)
begin
	if(SENDING_SERVICE_DATA == 0)
		byte_cntr = 0;
	else 
		byte_cntr =  byte_cntr + 1;
end

wire [7:0] MASK_Q_MARKER = (SENDING_SERVICE_DATA & (byte_cntr == 0)) ? 8'hFF : 0,
			  MASK_Q_FLAG   = (SENDING_SERVICE_DATA & (byte_cntr == 1)) ? 8'hFF : 0,	
			  MASK_Q_N1     = (SENDING_SERVICE_DATA & (byte_cntr == 2)) ? 8'hFF : 0,
			  MASK_Q_PL     = SENDING_PAYLOAD ? 8'hFF : 0;
			
assign q = MASK_Q_MARKER & `MARKER_MASTER  |
			  MASK_Q_FLAG   & `FLAG_CONTROL_COMMAND_WORD |
			  MASK_Q_N1	& 0 |
			  MASK_Q_PL & ccw_d;
			  
assign q_rdy = SENDING_SERVICE_DATA ? ~cd_busy & ~SERVICE_DATA_IS_SENT : ccw_d_rdy;
assign msg_end = ~tx_rdy & SENDING_PAYLOAD;

endmodule 

