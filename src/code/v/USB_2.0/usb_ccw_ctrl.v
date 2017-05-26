module usb_ccw_ctrl (
	input  clk,
	input  n_rst,
	input  ccw_accepted,
	output ccw_tx_rdy,
	input  ccw_rx_rdy,
	output ccw_buf_rdreq,
	input  ccw_buf_is_read,
	input  ccw_repeat_req,
	output n_rst_ccw_buf_ptrs
);

reg ccw_buf_has_data;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_buf_has_data = 0;
	else if(ccw_accepted | ccw_repeat_req)
		ccw_buf_has_data = 1;
	else if(ccw_buf_is_read)
		ccw_buf_has_data = 0;
end

reg ccw_rx_rdy_sync;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_rx_rdy_sync = 0;
	else
		ccw_rx_rdy_sync = ccw_rx_rdy;
end

reg ccw_buf_has_data_sync;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_buf_has_data_sync = 0;
	else 
		ccw_buf_has_data_sync = ccw_buf_has_data;
end

wire CCW_RX_RDY_TRIMMED = ccw_rx_rdy & ~ccw_rx_rdy_sync;
wire TICK_AFTER_CCW_BUF_HAS_DATA = ~ccw_buf_has_data & ccw_buf_has_data_sync; 

assign n_rst_ccw_buf_ptrs = ~TICK_AFTER_CCW_BUF_HAS_DATA;

assign ccw_buf_rdreq = CCW_RX_RDY_TRIMMED;

assign ccw_tx_rdy = ccw_buf_has_data | ccw_rx_rdy;


endmodule 
