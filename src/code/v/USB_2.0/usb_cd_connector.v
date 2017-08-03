module usb_cd_connector (
	input clk,  
	input n_rst,
	input [15:0] d_src,
	input [1:0] tx_rdy_src,
	
	input rd_a_src,
	input rd_nh_src,
	input rd_nl_src,
	input rd_d_src,
	
	output [1:0] rd_a_dst,
	output [1:0] rd_nh_dst,
	output [1:0] rd_nl_dst,
	output [1:0] rd_d_dst,
	
	output reg[7:0] q,
	input  pck_sent
);


endmodule 