module usb_ctrl_regs_reader (
	input clk,
	input n_rst,
	
	input rdreq,
	
	output reg tx_rdy,
	input  tx_ack, 

	input  st_rdreq,
	output reg st_tx_rdy,
	input  st_tx_ack,
	
	input [63:0] st_bytes,
	input [15:0] sdi_bytes,
	input [23:0] csi_bytes,
	
	output reg st_asserted,
	
	output reg[7:0] q,
	
	output reg st_last_byte,
	output reg sdi_last_byte,
	output reg csi_last_byte
);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		st_asserted = 0;
	else if(bc == 13)
		st_asserted = 0;
	else if(bc == 5)
		st_asserted = 1;
end


always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		st_tx_rdy = 0;
	else if(st_tx_ack)
		st_tx_rdy = 0;
	else if(st_rdreq)
		st_tx_rdy = 1;
end



always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tx_rdy = 0;
	else if(tx_ack)
		tx_rdy = 0;
	else if(rdreq)
		tx_rdy = 1;
	else if(bc == 14)
		tx_rdy = 1;
	else if(bc == 24)
		tx_rdy = 1;
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
			 
			 
wire ANY_TX_ACK = tx_ack | st_tx_ack;			 
			 
reg bc_en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		bc_en = 0;
	else if(bc == 35)
		bc_en = 0;
	else if(ANY_TX_ACK)
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
			
			17: q = 8'h4D;
			18: q = `SDI_CTRL_REG_ADDR;
			19: q = 0;
			20: q = 2;
			
			22: q = sdi1;
			23: q = sdi2;
			
			28: q = 8'h4D;
			29: q = `CSI_CTRL_REG_ADDR;
			30: q = 0;
			31: q = 3;
			
			33: q = csi1;
			34: q = csi2;
			35: q = csi3;
			
			default: q = 8'h5E;
			
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
		sdi_last_byte = (bc == 23);
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		csi_last_byte = 0;
	else 
		csi_last_byte = (bc == 35);
end

endmodule 

