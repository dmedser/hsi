module btc_ctrl (
	input clk, 
	input n_rst,
	input btc_tx_rdy,
	input btc_tx_en,
	input cd_busy,
	input [39:0] btc,
	output [7:0]q,
	output q_rdy,
	output msg_end
);

`include "src/code/vh/msg_defs.vh"	

reg tmp2;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tmp2 = 0;
	else if(btc_tx_rdy)
		tmp2 = 1;
	else
		tmp2 = 0;
end
wire ITS_TIME_TO_LATCH_BTC = ~btc_tx_rdy & tmp2; 

reg[39:0] btc_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		btc_reg = 0;
	else if(ITS_TIME_TO_LATCH_BTC)
		btc_reg = btc;
end

reg [4:0] byte_cntr;
always@(posedge cd_busy or negedge btc_tx_en)
begin
	if(btc_tx_en == 0)
		byte_cntr = 0;
	else 
		byte_cntr = byte_cntr + 1;	
end

wire [7:0] MASK_Q_MARKER = (byte_cntr == 0) ? 8'hFF : 0,
			  MASK_Q_FLAG   = (byte_cntr == 1) ? 8'hFF : 0,
			  MASK_Q_N1     = (byte_cntr == 2) ? 8'hFF : 0,
			  MASK_Q_N2     = (byte_cntr == 3) ? 8'hFF : 0,
			  MASK_Q_PL1    = (byte_cntr == 4) ? 8'hFF : 0,
			  MASK_Q_PL2    = (byte_cntr == 5) ? 8'hFF : 0,
		     MASK_Q_PL3    = (byte_cntr == 6) ? 8'hFF : 0,
			  MASK_Q_PL4    = (byte_cntr == 7) ? 8'hFF : 0,
			  MASK_Q_PL5    = (byte_cntr == 8) ? 8'hFF : 0;

assign q = MASK_Q_MARKER & `MARKER_MASTER |
			  MASK_Q_FLAG   & `FLAG_BOARD_TIME_CODE |
			  MASK_Q_N1     & 0 |
			  MASK_Q_N2     & 5 |
			  MASK_Q_PL1    & btc_reg[39:32] |
			  MASK_Q_PL2    & btc_reg[31:24] |
			  MASK_Q_PL3    & btc_reg[23:16] |
			  MASK_Q_PL4    & btc_reg[15:8]  |
			  MASK_Q_PL5    & btc_reg[7:0];
			  
assign q_rdy = (~cd_busy) & n_rst;

wire ITS_LAST_BYTE = (byte_cntr == 9);

reg tmp;
always@(posedge clk)
begin
	if(ITS_LAST_BYTE & cd_busy)
		tmp = 1;
	else
		tmp = 0;
end
assign msg_end = tmp & ~cd_busy; 
endmodule 
