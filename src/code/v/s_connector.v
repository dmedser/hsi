module s_connector (
	input  [1:0]  tx_state,
	input  [1:0]  d_rdy_src,
	output	     d_rdy_dst,
	input  [15:0] d_src,
	output [7:0]  d_dst
);

`define TX_STATE_SENDING_SDP tx_state[0]
`define TX_STATE_SENDING_CRC tx_state[1]

`define D_RDY_SDP d_rdy_src[0]
`define D_RDY_CRC	d_rdy_src[1]

`define D_SDP d_src[7:0]
`define D_CRC d_src[15:8]


assign d_rdy_dst = (`TX_STATE_SENDING_SDP & `D_RDY_SDP) |
						 (`TX_STATE_SENDING_CRC & `D_RDY_CRC);
						 
wire[7:0] MASK_D_SDP = `TX_STATE_SENDING_SDP ? 8'hFF: 0,
			 MASK_D_CRC = `TX_STATE_SENDING_CRC ? 8'hFF: 0;	
					
assign d_dst = (MASK_D_SDP & `D_SDP) |
					(MASK_D_CRC & `D_CRC);					
					
endmodule