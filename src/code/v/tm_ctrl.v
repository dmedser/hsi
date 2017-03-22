module tm_ctrl (
	input clk,
	input n_rst,
	input tm,
	input cd_busy,
	output [7:0] q,
	output q_rdy,
	output msg_end
);

`include "src/code/vh/msg_defs.vh"

assign q_rdy = (tmc_action == TMC_ACTION_SEND_MARKER) | (tmc_action == TMC_ACTION_SEND_FLAG) | (tmc_action == TMC_ACTION_SEND_N1) | (tmc_action == TMC_ACTION_SEND_N2); 
assign msg_end = (tmc_action == TMC_ACTION_SEND_MSG_END);

wire[7:0] q_src = (tmc_action == TMC_ACTION_SEND_MARKER) ? `MARKER_MASTER : `FLAG_TIME_MARK;
assign q = ((tmc_action == TMC_ACTION_CTRL)|(tmc_action == TMC_ACTION_SEND_N1)|(tmc_action == TMC_ACTION_SEND_N2)|(tmc_action == TMC_ACTION_SEND_MSG_END)) ? 0 : q_src;

reg[2:0] tmc_action;
parameter TMC_ACTION_CTRL			 = 0,
			 TMC_ACTION_SEND_MARKER  = 1,
			 TMC_ACTION_SEND_FLAG    = 2,
			 TMC_ACTION_SEND_N1		 = 3,
			 TMC_ACTION_SEND_N2		 = 4,
			 TMC_ACTION_SEND_MSG_END = 5;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			tmc_action = TMC_ACTION_CTRL;
		end
	else
		begin
			case(tmc_action)
			TMC_ACTION_CTRL:
				begin
					if(cd_busy)
						tmc_action = TMC_ACTION_CTRL; 
					else if(tm)
						tmc_action = TMC_ACTION_SEND_MARKER; 
					else if(N1_IS_SENT)
						tmc_action = TMC_ACTION_SEND_N2;
					else if(FLAG_IS_SENT)
						tmc_action = TMC_ACTION_SEND_N1;
					else if(MARKER_IS_SENT)
						tmc_action = TMC_ACTION_SEND_FLAG;
					else
						tmc_action = TMC_ACTION_CTRL;
					end
			TMC_ACTION_SEND_MARKER:
				begin
					if(cd_busy)
						tmc_action = TMC_ACTION_CTRL;
					else
						tmc_action = TMC_ACTION_SEND_MARKER;
				end
			TMC_ACTION_SEND_FLAG:
				begin
					if(cd_busy)
						tmc_action = TMC_ACTION_CTRL;
					else
						tmc_action = TMC_ACTION_SEND_FLAG;
				end
			TMC_ACTION_SEND_N1:
				begin
					if(cd_busy)
						tmc_action = TMC_ACTION_CTRL;
					else
						tmc_action = TMC_ACTION_SEND_N1;
					end
			TMC_ACTION_SEND_N2:
				begin
					if(cd_busy)
						tmc_action = TMC_ACTION_SEND_MSG_END;
					else
						tmc_action = TMC_ACTION_SEND_N2;
					end
			TMC_ACTION_SEND_MSG_END:
				begin
					tmc_action = TMC_ACTION_CTRL;
				end
			default:
				begin
				
				end
			endcase
		end
end


reg MARKER_IS_SENT;
reg FLAG_IS_SENT;
reg N1_IS_SENT;
wire n_rst_flags = n_rst & ~(msg_end);

always@(posedge clk or negedge n_rst_flags)
begin
	if(n_rst_flags == 0)
		MARKER_IS_SENT = 0;
	else if(tmc_action == TMC_ACTION_SEND_MARKER)
		MARKER_IS_SENT = 1;
end

always@(posedge clk or negedge n_rst_flags)
begin
	if(n_rst_flags == 0)
		FLAG_IS_SENT = 0;
	else if(tmc_action == TMC_ACTION_SEND_FLAG)
		FLAG_IS_SENT = 1;
end

always@(posedge clk or negedge n_rst_flags)
begin
	if(n_rst_flags == 0)
		N1_IS_SENT = 0;
	else if(tmc_action == TMC_ACTION_SEND_N1)
		N1_IS_SENT = 1;
end

endmodule
