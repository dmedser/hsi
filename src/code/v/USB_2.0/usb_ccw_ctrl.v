module usb_ccw_ctrl (
	input  clk_prj,
	input  clk_ftdi,
	input  n_rst,
	input  ccw_accepted,
	output ccw_tx_rdy,
	input  ccw_rx_rdy,
	
	input  ccwb_is_read,
	input  ccw_repeat_req,
	output ccwb_rdreq
);


reg ccwb_has_data;
always@(posedge clk_prj or negedge n_rst)
begin
	if(n_rst == 0)
		ccwb_has_data = 0;
	else if(ccw_accepted | ccw_repeat_req)
		ccwb_has_data = 1;
	else if(ccwb_is_read)
		ccwb_has_data = 0;
end


wire CCW_RX_RDY_TRIMMED_TO_FTDI_TICK = ccw_rx_rdy & ~ccw_rx_rdy_sync_ftdi;
reg ccw_rx_rdy_sync_ftdi;
always@(posedge clk_ftdi or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_rx_rdy_sync_ftdi = 0;
	else
		ccw_rx_rdy_sync_ftdi = ccw_rx_rdy;
end


assign ccwb_rdreq = CCW_RX_RDY_TRIMMED_TO_FTDI_TICK;

assign ccw_tx_rdy = ccwb_has_data | ccw_rx_rdy;


endmodule 
