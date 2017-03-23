module crc_sender (
	input clk,
	input n_rst,
	input [15:0] crc,
	input crc_rdy,
	input cd_busy,
	output q_rdy,
	output [7:0] q,
	output msg_end
);

`define H crc_reg[15:8]
`define L crc_reg[7:0]

reg [1:0] byte_cntr;
always@(posedge cd_busy or negedge n_rst)
begin
	if(n_rst == 0)
		byte_cntr = 0;
	else
		byte_cntr = byte_cntr + 1;	
end

reg[15:0] crc_reg;
always@(posedge crc_rdy)
begin
	crc_reg = crc;
end


wire [7:0] MASK_Q_CRC_H = (byte_cntr == 0) ? 8'hFF : 0;
wire [7:0] MASK_Q_CRC_L = (byte_cntr == 1) ? 8'hFF : 0;

assign q = MASK_Q_CRC_H & `H |
			  MASK_Q_CRC_L & `L;

assign q_rdy = (~cd_busy) & n_rst;

wire ITS_LAST_BYTE = (byte_cntr == 2) & cd_busy;

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