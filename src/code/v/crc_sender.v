module crc_sender (
	input clk,
	input n_rst,
	input [15:0] crc,
	input crc_rdy,
	output reg crc_n_rst,
	input cd_busy,
	output q_rdy,
	output [7:0] q,
	output msg_end
);

`define H crc_reg[15:8]
`define L crc_reg[7:0]

assign q_rdy = (sndr_state == SNDR_STATE_SEND_H)|(sndr_state == SNDR_STATE_SEND_L);

wire[7:0] q_src = (sndr_state == SNDR_STATE_SEND_H) ? `H : `L;
assign q = (sndr_state == SNDR_STATE_CTRL)|(sndr_state == SNDR_STATE_RDY) ? 0 : q_src;

assign msg_end = (sndr_state == SNDR_STATE_RDY);
reg [15:0] crc_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			crc_reg = 0;
			crc_n_rst = 1;
		end
	else if(crc_rdy)
		begin
			crc_reg = crc;
			crc_n_rst = 0;
		end
	else
		begin
			crc_n_rst = 1;
		end
end

reg h_tx_rdy;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		h_tx_rdy = 0;
	else if(crc_rdy)
		h_tx_rdy = 1;
	else if(sndr_state == SNDR_STATE_SEND_H)
		h_tx_rdy = 0;
end

reg l_tx_rdy; 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		l_tx_rdy = 0;
	else if(sndr_state == SNDR_STATE_SEND_H)
		l_tx_rdy = 1;
	else if(sndr_state == SNDR_STATE_SEND_L)
		l_tx_rdy = 0;
end

reg crc_sent;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		crc_sent = 0;
	else if(sndr_state == SNDR_STATE_SEND_L)
		crc_sent = 1;
	else if(sndr_state == SNDR_STATE_RDY)
		crc_sent = 0;
end

reg[1:0] sndr_state;
parameter SNDR_STATE_CTRL = 0,
			 SNDR_STATE_SEND_H = 1,
			 SNDR_STATE_SEND_L = 2,
			 SNDR_STATE_RDY = 3;

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			sndr_state = SNDR_STATE_CTRL;
		end
	else 
		case(sndr_state)
		SNDR_STATE_CTRL:
			begin
				if(cd_busy)
					sndr_state = SNDR_STATE_CTRL;
				else if(crc_sent)
					sndr_state = SNDR_STATE_RDY;
				else if(l_tx_rdy)
					sndr_state = SNDR_STATE_SEND_L;
				else if(h_tx_rdy)
					sndr_state = SNDR_STATE_SEND_H;
				else
					sndr_state = SNDR_STATE_CTRL;
			end
		SNDR_STATE_SEND_H:
			begin
				if(cd_busy)
					sndr_state = SNDR_STATE_CTRL;
				else
					sndr_state = SNDR_STATE_SEND_H;
			end
		SNDR_STATE_SEND_L:
			begin
				if(cd_busy)
					sndr_state = SNDR_STATE_CTRL;
				else
					sndr_state = SNDR_STATE_SEND_L;
			end
		SNDR_STATE_RDY:
			begin
				sndr_state = SNDR_STATE_CTRL;
			end
		default:
			begin
			
			end
		endcase
end

endmodule 