module connector (
	input  [5:0]  common_state,
	input  [5:0]  d_rdy_src,
	output	     d_rdy_dst,
	input  [47:0] d_src,
	output [7:0]  d_dst
);

`define COM_STATE_SENDING_TM  common_state[0]
`define COM_STATE_SENDING_BTC common_state[1]
`define COM_STATE_SENDING_SR	common_state[2]
`define COM_STATE_SENDING_DPR common_state[3]
`define COM_STATE_SENDING_CCW common_state[4]
`define COM_STATE_SENDING_CRC common_state[5]

`define D_RDY_TM_CTRL  d_rdy_src[0]
`define D_RDY_BTC_CTRL d_rdy_src[1]
`define D_RDY_SR_CTRL  d_rdy_src[2]
`define D_RDY_DPR_CTRL d_rdy_src[3]
`define D_RDY_CCW_CTRL d_rdy_src[4]
`define D_RDY_CRC_SNDR d_rdy_src[5] 

`define D_TM_CTRL  d_src[7:0]
`define D_BTC_CTRL d_src[15:8]
`define D_SR_CTRL  d_src[23:16]
`define D_DPR_CTRL d_src[31:24]
`define D_CCW_CTRL d_src[39:32]
`define D_CRC_SNDR d_src[47:40]

assign d_rdy_dst = (`COM_STATE_SENDING_TM  & `D_RDY_TM_CTRL)  |
						 (`COM_STATE_SENDING_BTC & `D_RDY_BTC_CTRL) |
						 (`COM_STATE_SENDING_SR  & `D_RDY_SR_CTRL)  |
						 (`COM_STATE_SENDING_DPR & `D_RDY_DPR_CTRL) |
						 (`COM_STATE_SENDING_CCW & `D_RDY_CCW_CTRL) |
						 (`COM_STATE_SENDING_CRC & `D_RDY_CRC_SNDR);

wire[7:0] MASK_D_TM  = `COM_STATE_SENDING_TM  ? 8'hFF: 0;
wire[7:0] MASK_D_BTC = `COM_STATE_SENDING_BTC ? 8'hFF: 0;
wire[7:0] MASK_D_SR  = `COM_STATE_SENDING_SR  ? 8'hFF: 0;
wire[7:0] MASK_D_DPR = `COM_STATE_SENDING_DPR ? 8'hFF: 0;
wire[7:0] MASK_D_CCW = `COM_STATE_SENDING_CCW ? 8'hFF: 0;
wire[7:0] MASK_D_CRC = `COM_STATE_SENDING_CRC ? 8'hFF: 0;						 
						 
assign d_dst = (MASK_D_TM  & `D_TM_CTRL)  |
					(MASK_D_BTC & `D_BTC_CTRL) |
					(MASK_D_SR  & `D_SR_CTRL)  |
					(MASK_D_DPR & `D_DPR_CTRL) |
					(MASK_D_CCW & `D_CCW_CTRL) |
					(MASK_D_CRC & `D_CRC_SNDR);
					
endmodule