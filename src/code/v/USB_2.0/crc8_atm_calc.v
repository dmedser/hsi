module crc8_atm_calc (
  input clk,
  input n_rst,
  input en,
  input [7:0] d,
  output reg [7:0] crc
);

wire[7:0] c;

assign c[0] = crc[0] ^ crc[6] ^ crc[7] ^ d[0] ^ d[6] ^ d[7];
assign c[1] = crc[0] ^ crc[1] ^ crc[6] ^ d[0] ^ d[1] ^ d[6];
assign c[2] = crc[0] ^ crc[1] ^ crc[2] ^ crc[6] ^ d[0] ^ d[1] ^ d[2] ^ d[6];
assign c[3] = crc[1] ^ crc[2] ^ crc[3] ^ crc[7] ^ d[1] ^ d[2] ^ d[3] ^ d[7];
assign c[4] = crc[2] ^ crc[3] ^ crc[4] ^ d[2] ^ d[3] ^ d[4];
assign c[5] = crc[3] ^ crc[4] ^ crc[5] ^ d[3] ^ d[4] ^ d[5];
assign c[6] = crc[4] ^ crc[5] ^ crc[6] ^ d[4] ^ d[5] ^ d[6];
assign c[7] = crc[5] ^ crc[6] ^ crc[7] ^ d[5] ^ d[6] ^ d[7];

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) 
		crc = 0;
    else
      crc = en ? c : crc;
end
endmodule