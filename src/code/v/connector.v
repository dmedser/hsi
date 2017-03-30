module connector (
	input  [5:0]  common_state,
	input  [3:0]  d_rdy_src,
	output	     d_rdy_dst,
	input  [31:0] d_src,
	output [7:0]  d_dst
);

`define COM_STATE_SENDING_TM  common_state[0]
`define COM_STATE_SENDING_BTC common_state[1]
`define COM_STATE_SENDING_SR	common_state[2]
`define COM_STATE_SENDING_DPR common_state[3]
`define COM_STATE_SENDING_CCW common_state[4]
`define COM_STATE_SENDING_CRC common_state[5]

`define D_RDY_TM_SR_DPR  d_rdy_src[0]
`define D_RDY_BTC		 	 d_rdy_src[1]
`define D_RDY_CCW			 d_rdy_src[2]
`define D_RDY_CRC		 	 d_rdy_src[3] 

`define D_TM_SR_DPR  d_src[7:0]
`define D_BTC  		d_src[15:8]
`define D_CCW 	  	   d_src[23:16]
`define D_CRC 		   d_src[31:24]

assign d_rdy_dst = (`COM_STATE_SENDING_TM  & `D_RDY_TM_SR_DPR) |
						 (`COM_STATE_SENDING_BTC & `D_RDY_BTC) |
						 (`COM_STATE_SENDING_SR  & `D_RDY_TM_SR_DPR) |
						 (`COM_STATE_SENDING_DPR & `D_RDY_TM_SR_DPR) |
						 (`COM_STATE_SENDING_CCW & `D_RDY_CCW) |
						 (`COM_STATE_SENDING_CRC & `D_RDY_CRC);

wire[7:0] MASK_D_TM  = `COM_STATE_SENDING_TM  ? 8'hFF: 0,
			 MASK_D_BTC = `COM_STATE_SENDING_BTC ? 8'hFF: 0,
			 MASK_D_SR  = `COM_STATE_SENDING_SR  ? 8'hFF: 0,
			 MASK_D_DPR = `COM_STATE_SENDING_DPR ? 8'hFF: 0,
			 MASK_D_CCW = `COM_STATE_SENDING_CCW ? 8'hFF: 0,
			 MASK_D_CRC = `COM_STATE_SENDING_CRC ? 8'hFF: 0;	
					
assign d_dst = (MASK_D_TM  & `D_TM_SR_DPR) |
					(MASK_D_BTC & `D_BTC) |
					(MASK_D_SR  & `D_TM_SR_DPR) |
					(MASK_D_DPR & `D_TM_SR_DPR) |
					(MASK_D_CCW & `D_CCW) |
					(MASK_D_CRC & `D_CRC);					
					
endmodule