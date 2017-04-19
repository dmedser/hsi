module ccw_gen (
	input clk,
	input n_rst,
	input ccw_accepted,
	input ccw_repeat_req,
	output ccw_tx_rdy,
	input ccw_tx_en,
	output [7:0] ccw_d,
	output ccw_d_rdy,
	input ccw_d_sending
);

`include "src/code/vh/hsi_config.vh"

assign ccw_d = SENDING_N ? `CCW_LEN : ccw_d_sync;
assign ccw_d_rdy = ~ccw_d_sending & (SENDING_N|SENDING_DATA);

reg ccwg_has_data;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccwg_has_data = 0;
	else if(ccw_accepted | ccw_repeat_req)
		ccwg_has_data = 1;
	else if(SENDING_DATA & (ccw_d == `CCW_LEN))
		ccwg_has_data = 0;
end

assign ccw_tx_rdy = ccwg_has_data | ccw_d_sending;

reg[1:0] ccwg_state;
parameter CCWG_STATE_CTRL = 0,
			 CCWG_STATE_SENDING_N = 1,
			 CCWG_STATE_SENDING_DATA = 2;
wire SENDING_N = (ccwg_state == CCWG_STATE_SENDING_N);
wire SENDING_DATA = (ccwg_state == CCWG_STATE_SENDING_DATA);
always@(posedge clk or negedge n_rst) 
begin
	if(n_rst == 0)
		ccwg_state = CCWG_STATE_CTRL;
	else 
		begin
			case(ccwg_state)
			CCWG_STATE_CTRL:
				begin
					if(ccw_tx_en)
						ccwg_state = CCWG_STATE_SENDING_N;
					else 
						ccwg_state = CCWG_STATE_CTRL;
				end
			CCWG_STATE_SENDING_N:
				begin
					if(ccw_d_sending)
						ccwg_state = CCWG_STATE_SENDING_DATA;
					else 
						ccwg_state = CCWG_STATE_SENDING_N;	
				end
			CCWG_STATE_SENDING_DATA:
				begin
					if(~ccw_tx_rdy)
						ccwg_state = CCWG_STATE_CTRL;
					else 
						ccwg_state = CCWG_STATE_SENDING_DATA;
				end
			default:
				begin
				
				end
			endcase
		end
end

reg[7:0] ccw_d_sync;
wire N_RST_CCW_D_SYNC = n_rst & ~SENDING_N;
always@(posedge ccw_d_sending or negedge N_RST_CCW_D_SYNC)
begin
	if(N_RST_CCW_D_SYNC == 0)
		ccw_d_sync = 0;
	else if(SENDING_DATA)
		ccw_d_sync = ccw_d_sync + 1;
end

endmodule 

