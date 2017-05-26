module ccw_ctrl (
	input  clk,
	input  n_rst,
	input  [7:0] ccw_byte,
	input  ccw_tx_rdy,
	output ccw_rx_rdy,
	input  cd_busy,
	output [7:0] q,
	output q_rdy,
	output msg_end
);

`include "src/code/vh/msg_defs.vh"	

wire MARKER_AND_FLAG_ARE_SENT = (byte_cntr == 2);
wire N_RST_BYTE_CNTR = n_rst & ~msg_end;
reg[1:0] byte_cntr;

always@(posedge cd_busy or negedge N_RST_BYTE_CNTR)
begin
	if(N_RST_BYTE_CNTR == 0)
		byte_cntr = 0;
	else if(ccw_tx_rdy & ~MARKER_AND_FLAG_ARE_SENT)
		byte_cntr = byte_cntr + 1;
end 
			 
assign ccw_rx_rdy = ccw_tx_rdy & MARKER_AND_FLAG_ARE_SENT & ~cd_busy;

reg ccw_rx_rdy_sync;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_rx_rdy_sync = 0;
	else 
		ccw_rx_rdy_sync = ccw_rx_rdy;
end

assign q_rdy = (ccw_tx_rdy & ~MARKER_AND_FLAG_ARE_SENT & ~cd_busy) | ccw_rx_rdy_sync; 

wire[7:0] MASK_Q_MARKER  = (byte_cntr == 0)   ? 8'hFF : 0,
			 MASK_Q_FLAG    = (byte_cntr == 1)   ? 8'hFF : 0,
			 MASK_Q_PAYLOAD = MARKER_AND_FLAG_ARE_SENT ? 8'hFF : 0; 
			 
assign q = MASK_Q_MARKER  & `MARKER_MASTER |
			  MASK_Q_FLAG    & `FLAG_CONTROL_COMMAND_WORD |
			  MASK_Q_PAYLOAD & ccw_byte;  

reg ccw_tx_rdy_sync;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_tx_rdy_sync = 0;
	else
		ccw_tx_rdy_sync = ccw_tx_rdy;
end

wire TICK_AFTER_CCW_TX_RDY = ~ccw_tx_rdy & ccw_tx_rdy_sync;

assign msg_end = TICK_AFTER_CCW_TX_RDY;

endmodule 

