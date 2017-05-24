module usb_ccw_ctrl (
	input  clk,
	input  n_rst,
	input  [7:0] d,
	input  d_accepted,
	output reg d_accept_en,
	input  cd_busy,
	output ccw_tx_rdy,
	output [7:0] ccw_d,
	output ccw_d_rdy
);

`include "src/code/vh/usb_ctrl_regs_addrs.vh"

reg ccw_accepted;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ccw_accepted = 0;
	else if(~d_accepted)
		ccw_accepted = 0;
	else if(d_accepted & (d == `CCW_BUF_ADDR))
		ccw_accepted = 1;
end

wire N_RST_D_ACCEPT_EN = n_rst & ccw_accepted;
always@(posedge clk or negedge N_RST_D_ACCEPT_EN)
begin
	if(N_RST_D_ACCEPT_EN == 0)
		d_accept_en = 1;
	else 
		d_accept_en = ~d_accept_en;
end

assign ccw_d = d_accept_en ? d : 0;




endmodule 
