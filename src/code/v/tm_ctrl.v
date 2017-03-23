module tm_ctrl(
	input clk,
	input n_rst,
	input cd_busy,
	output [7:0]q,
	output q_rdy,
	output msg_end
);

`include "src/code/vh/msg_defs.vh"	

reg [1:0] byte_cntr;
always@(posedge cd_busy or negedge n_rst)
begin
	if(n_rst == 0)
		byte_cntr = 0;
	else
		byte_cntr = byte_cntr + 1;	
end

wire [7:0] MASK_Q_MARKER = (byte_cntr == 0) ? 8'hFF : 0;
wire [7:0] MASK_Q_FLAG   = (byte_cntr == 1) ? 8'hFF : 0;

assign q = MASK_Q_MARKER & `MARKER_MASTER |
			  MASK_Q_FLAG   & `FLAG_TIME_MARK;

assign q_rdy = (~cd_busy) & n_rst;

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