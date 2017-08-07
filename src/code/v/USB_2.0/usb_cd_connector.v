module usb_cd_connector (
	input  clk,  
	input  n_rst,
	
	input  [15:0] d,
	
	input  [1:0] tx_rdy_src,
	output tx_rdy_dst,
	
	input  tx_ack_src,
	output [1:0] tx_ack_dst,
	
	input [1:0] last_byte_src,
	output last_byte_dst,
	
	output [7:0] q,
	input  pck_sent
);

wire CRS_LAST_BYTE  = last_byte_src[0];
wire MNTR_LAST_BYTE = last_byte_src[1];
 
assign last_byte_dst = CRS_LAST_BYTE | MNTR_LAST_BYTE; 
// [0] crs
// [1] mntr

assign tx_ack_dst[0] = crs_send ? tx_ack_src : 0;
assign tx_ack_dst[1] = crs_send ? 0 : tx_ack_src;

wire CRS_TX_RDY  = tx_rdy_src[0];
wire MNTR_TX_RDY = tx_rdy_src[1];
	 
reg crs_send;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)	
		crs_send = 0;
	else if(pck_sent)
		crs_send = 0;
	else if(CRS_TX_RDY)
		crs_send = 1;
end

wire[7:0] CRS_D  = d[15:8],
		    MNTR_D = d[7:0];

assign q = crs_send ? CRS_D : MNTR_D;

assign tx_rdy_dst = CRS_TX_RDY | MNTR_TX_RDY;

endmodule 