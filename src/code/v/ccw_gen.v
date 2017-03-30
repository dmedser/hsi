module ccw_gen (
	input clk,
	input n_rst,
	input pre_tm,
	output [7:0] ccw_d,
	input ccw_clk,
	output reg ccw_tx_rdy,
	input ccw_tx_en
);

wire[7:0] q_src = ccw_tx_en ? ccw_pl : ccw_len;
wire[7:0] ccw_pl_async = ccw_tx_rdy ? ccw_pl_sync : 0;

wire[7:0] ccw_pl = ccw_pl_async;

reg tmp;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tmp = 0;
	else if(pre_tm)
		tmp = 1;
	else 
		tmp = 0;
end

wire CCW_TX_START = pre_tm & ~tmp;

assign ccw_d = q_src;
 
reg [5:0] ccw_len;
always@(posedge ccw_clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_len = 62;
	else if(CCW_TX_START)
		ccw_len = 62;
	else if(ccw_tx_en)
		ccw_len = ccw_len - 1;
end


reg[7:0] ccw_pl_sync;
always@(posedge ccw_clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_pl_sync = 8'hAB;
	else if(CCW_TX_START)
		ccw_pl_sync = 8'hAB;
	else if(ccw_tx_en)
		ccw_pl_sync = ccw_pl_sync + 1;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_tx_rdy = 0;
	else if (CCW_TX_START)
		ccw_tx_rdy = 1;
	else if (ccw_len == 0)
		ccw_tx_rdy = 0;
end

endmodule
