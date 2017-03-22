module crc16_citt_calc(
	input clk,
	input n_rst,
	input en,
	input [7:0] d8,
	input start,
	output [15:0] crc,
	output crc_updated
);

shift_counter SH_CNTR(
	.clk(clk),
	.en(en & (~start)),
	.crc_updated(crc_updated)
);

calc_core CLAC_CORE (
	.clk(clk),
	.n_rst(n_rst),
	.en(en),
	.d8(d8),
	.start(start),
	.crc(crc)
);
endmodule 


module calc_core (
	input clk,
	input n_rst,
	input en,
	input [7:0] d8,
	input start,
	output reg [15:0] crc
);

wire[15:0] d16;
assign d16[15:8] = d8;

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			crc = 16'hFFFF;
		end
	else if(en)
		begin
			if(start)
				begin
					crc = crc^d16;
				end
			else
				begin
					crc = (crc & 16'h8000) ? (crc << 1)^16'h1021 : (crc << 1);
				end
		end
end
endmodule 


module shift_counter (
	input clk,
	input en,
	output crc_updated
);

reg [2:0] sh_cntr;
parameter CRC_UPDATE_TIME = 7;
assign crc_updated = (sh_cntr == CRC_UPDATE_TIME);
always@(posedge clk)
begin
	if(en)
		begin
			sh_cntr = sh_cntr + 1;
		end
end
endmodule