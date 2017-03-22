module crc16_citt_calc (
	input clk,
	input n_rst,
	input en,
	input [7:0] d,
	output reg [15:0] crc
);

wire [15:0] c;
assign c[0] = crc[8] ^ crc[12] ^ d[0] ^ d[4];
assign c[1] = crc[9] ^ crc[13] ^ d[1] ^ d[5];
assign c[2] = crc[10] ^ crc[14] ^ d[2] ^ d[6];
assign c[3] = crc[11] ^ crc[15] ^ d[3] ^ d[7];
assign c[4] = crc[12] ^ d[4];
assign c[5] = crc[8] ^ crc[12] ^ crc[13] ^ d[0] ^ d[4] ^ d[5];
assign c[6] = crc[9] ^ crc[13] ^ crc[14] ^ d[1] ^ d[5] ^ d[6];
assign c[7] = crc[10] ^ crc[14] ^ crc[15] ^ d[2] ^ d[6] ^ d[7];
assign c[8] = crc[0] ^ crc[11] ^ crc[15] ^ d[3] ^ d[7];
assign c[9] = crc[1] ^ crc[12] ^ d[4];
assign c[10] = crc[2] ^ crc[13] ^ d[5];
assign c[11] = crc[3] ^ crc[14] ^ d[6];
assign c[12] = crc[4] ^ crc[8] ^ crc[12] ^ crc[15] ^ d[0] ^ d[4] ^ d[7];
assign c[13] = crc[5] ^ crc[9] ^ crc[13] ^ d[1] ^ d[5];
assign c[14] = crc[6] ^ crc[10] ^ crc[14] ^ d[2] ^ d[6];
assign c[15] = crc[7] ^ crc[11] ^ crc[15] ^ d[3] ^ d[7];

always@(posedge clk or negedge n_rst) 
begin
	if(n_rst == 0)
		crc = 16'hFFFF;
   else 
		crc = en ? c : crc;
end
endmodule 