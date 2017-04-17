module m_err_check (
	input clk,
	input n_rst,
	input [7:0] d,
	input d_rdy,

	output reg rx_service_req,
	output reg rx_sd_busy,

	input pb_err,
	input [15:0] crc,
	output crc_update_disable,
	output crc_rst,
	input rx_frame_end,
	output [5:0] rx_errs
);

`include "src/code/vh/msg_defs.vh"

`define err_ok  rx_errs[0]
`define err_mrk rx_errs[1]
`define err_sts rx_errs[2]
`define err_n   rx_errs[3]
`define err_pb  rx_errs[4]
`define err_crc rx_errs[5]

`define ERR_IN_MSG  d[0]
`define SERVICE_REQ d[1]
`define SD_BUSY     d[2]

reg tmp;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tmp = 0;
	else if(rx_frame_end)
		tmp = 1;
	else 
		tmp = 0;
end

wire tick_after_msg_end = ~rx_frame_end & tmp;
wire N_RST_BY_TICK_AFTER_MSG_END = n_rst & ~tick_after_msg_end;
reg[10:0] b_cntr;
always@(posedge d_rdy or negedge N_RST_BY_TICK_AFTER_MSG_END)
begin
	if(N_RST_BY_TICK_AFTER_MSG_END == 0)
		b_cntr = 0;
	else 
		b_cntr = b_cntr + 1;
end

reg received_mrk_right;
always@(posedge clk or negedge N_RST_BY_TICK_AFTER_MSG_END)
begin
	if(N_RST_BY_TICK_AFTER_MSG_END == 0)
		received_mrk_right = 0;
	else if((b_cntr == 1) & d_rdy & (d == `MARKER_SLAVE))
		received_mrk_right = 1;
end


reg err_in_msg;
always@(posedge clk or negedge N_RST_BY_TICK_AFTER_MSG_END)
begin
	if(N_RST_BY_TICK_AFTER_MSG_END == 0)
		err_in_msg = 0;
	else if((b_cntr == 2) & d_rdy & `ERR_IN_MSG)
		err_in_msg = 1;
end


always@(posedge clk or negedge N_RST_BY_TICK_AFTER_MSG_END)
begin
	if(N_RST_BY_TICK_AFTER_MSG_END == 0)
		rx_service_req = 0;
	else if((b_cntr == 2) & d_rdy & `SERVICE_REQ)
		rx_service_req = 1;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		rx_sd_busy = 0;
	else if((b_cntr == 2) & d_rdy)
		rx_sd_busy = `SD_BUSY;
end

reg[15:0] received_n;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		received_n[15:8] = 0;	
	else if((b_cntr == 3) & d_rdy)
		received_n[15:8] = d;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		received_n[7:0] = 0;	
	else if((b_cntr == 4) & d_rdy)
		received_n[7:0] = d;
end

reg received_crc_h_right;
always@(posedge clk or negedge N_RST_BY_TICK_AFTER_MSG_END)
begin
	if(N_RST_BY_TICK_AFTER_MSG_END == 0)
		received_crc_h_right = 0;	
	else if((b_cntr == (received_n + 5)) & d_rdy)
		received_crc_h_right = 1;
end

reg pb_err_reg;
always@(posedge clk or negedge N_RST_BY_TICK_AFTER_MSG_END)
begin
	if(N_RST_BY_TICK_AFTER_MSG_END == 0)
		pb_err_reg = 0;
	else if(pb_err)
		pb_err_reg = 1;
end

assign crc_update_disable = (b_cntr > (received_n + 4)); 
assign crc_rst = tick_after_msg_end;

assign `err_ok  = rx_frame_end & ~(`err_mrk | `err_sts | `err_n | `err_pb | `err_crc);
assign `err_mrk = rx_frame_end & ~received_mrk_right;
assign `err_sts = rx_frame_end & err_in_msg;
assign `err_n   = rx_frame_end & ~(received_n == (b_cntr - 6));
assign `err_pb  = rx_frame_end & pb_err_reg;
assign `err_crc = rx_frame_end & ~(received_crc_h_right & (d == crc[7:0]));  
endmodule 