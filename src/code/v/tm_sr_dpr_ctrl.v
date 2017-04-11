module tm_sr_dpr_ctrl (
	input clk,
	input [2:0] tx_state,
	input cd_busy,
	output [7:0]q,
	output q_rdy,
	output msg_end
);

`define SENDING_TM  tx_state[0]
`define SENDING_SR  tx_state[1]
`define SENDING_DPR tx_state[2]

`include "src/code/vh/msg_defs.vh"	

wire tx_en = `SENDING_TM|`SENDING_SR|`SENDING_DPR;

reg[1:0] byte_cntr;
always@(posedge cd_busy or negedge tx_en)
begin
	if(tx_en == 0)
		byte_cntr = 0;
	else 
		byte_cntr = byte_cntr + 1;	
end

wire[7:0] MASK_Q_MARKER = (byte_cntr == 0) ? 8'hFF : 0,
			 MASK_Q_FLAG   = (byte_cntr == 1) ? 8'hFF : 0;

wire[7:0] MASK_SENDING_TM  = `SENDING_TM  ? 8'hFF : 0,
			 MASK_SENDING_SR  = `SENDING_SR  ? 8'hFF : 0,
			 MASK_SENDING_DPR = `SENDING_DPR ? 8'hFF : 0;
			 
wire[7:0] FLAG_SRC = MASK_SENDING_TM  & `FLAG_TIME_MARK |
							MASK_SENDING_SR  & `FLAG_STATUS_REQUEST |
							MASK_SENDING_DPR & `FLAG_DATA_PACKET_REQUEST;
							
assign q = MASK_Q_MARKER & `MARKER_MASTER |
			  MASK_Q_FLAG   & FLAG_SRC;

assign q_rdy = (~cd_busy) & tx_en;

wire ITS_LAST_BYTE = (byte_cntr == 3);

reg tmp;
always@(posedge clk)
begin
	if(ITS_LAST_BYTE)
		tmp = 1;
	else
		tmp = 0;
end

assign msg_end = tmp & ~ITS_LAST_BYTE; 
			 
endmodule 
