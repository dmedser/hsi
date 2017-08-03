module usb_ctrl_regs_reader (
	input clk,
	input n_rst,
	
	input l00_ms_is_left,
	input st_rdreq, 
	
	output tx_rdy,
	input  tx_ack, 
	
	
	input [63:0] st_bytes,
	input [15:0] sdi_bytes,
	input [23:0] csi_bytes,
		
	output reg[7:0] q,
	
	output reg st_last_byte,
	output reg sdi_last_byte,
	output reg csi_last_byte
);

assign tx_rdy = all_crs_tx_rdy | str_tx_rdy;

reg all_crs_tx_rdy;			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		all_crs_tx_rdy = 0;
	else if(tx_ack)
		all_crs_tx_rdy = 0;
	else if(l00_ms_is_left)
		all_crs_tx_rdy = 1;
	else if(bc == 13)
		all_crs_tx_rdy = 1;
	else if(bc == 23)
		all_crs_tx_rdy = 1;
end




reg str_tx_rdy;			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		str_tx_rdy = 0;
	else if(tx_ack)
		str_tx_rdy = 0;
	else if(st_rdreq)
		str_tx_rdy = 1;
end	


`include "src/code/vh/usb_ctrl_regs_addrs.vh"

wire[7:0] st1 = st_bytes[63:56], st5 = st_bytes[31:24],
  		    st2 = st_bytes[55:48], st6 = st_bytes[23:16],
		    st3 = st_bytes[47:40], st7 = st_bytes[15:8],
		    st4 = st_bytes[39:32], st8 = st_bytes[7:0];
			  
wire[7:0] sdi1 = sdi_bytes[15:8],
			 sdi2 = sdi_bytes[7:0];
			  
wire[7:0] csi1 = csi_bytes[23:16],
	       csi2 = csi_bytes[15:8],
	       csi3 = csi_bytes[7:0];

			 
			 
reg bc_en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		bc_en = 0;
	else if(bc == 34)
		bc_en = 0;
	else if(tx_ack)
		bc_en = 1;
end

reg[5:0] bc;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		bc = 0;
	else if(bc_en)
		bc = bc + 1;
	else 
		bc = 0;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		q = 0;
	else 
		begin
			case(bc)
			0: q = bc_en ? 8'h4D : 8'h5E;
			1: q = `SYS_TIME_REG_ADDR;
			2: q = 0;
			3: q = 8;
			
			5: q = st1;
			6: q = st2;
			7: q = st3;
			8: q = st4;
			9: q = st5;
			10: q = st6;
			11: q = st7;
			12: q = st8;
			
			15: q = 8'h5E;
			16: q = 8'h4D;
			17: q = `SDI_CTRL_REG_ADDR;
			18: q = 0;
			19: q = 2;
			
			21: q = sdi1;
			22: q = sdi2;
			
			25: q = 8'h5E;
			26: q = 8'h4D;
			27: q = `CSI_CTRL_REG_ADDR;
			28: q = 0;
			29: q = 3;
			
			31: q = csi1;
			32: q = csi2;
			33: q = csi3;
			
			default: q = 8'hFF;
			endcase
		end
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		st_last_byte = 0;
	else 
		st_last_byte = (bc == 12);
end	

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		sdi_last_byte = 0;
	else 
		sdi_last_byte = (bc == 22);
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		csi_last_byte = 0;
	else 
		csi_last_byte = (bc == 33);
end

endmodule 

