module usb_ctrl_regs_reader (
	input clk,
	input n_rst,
	
	output reg usb_tx_start,
	input  l00_ms_is_left,
	
	input [63:0] st_bytes,
	
	input [15:0] sdi_bytes,
	
	input [23:0] csi_bytes,
		
	output reg[7:0] q,
   input  rdreq,
	output last_byte 
);

`include "src/code/vh/usb_ctrl_regs_addrs.vh"

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		usb_tx_start = 0;
	else if(l00_ms_is_left)
		usb_tx_start = 1;
	else if(CRS_ARE_READ)
		usb_tx_start = 0;
end


assign last_byte = ST_LAST_BYTE | SDI_LAST_BYTE | CSI_LAST_BYTE; 

wire[7:0] st_b1 = st_bytes[63:56], st_b5 = st_bytes[31:24],
  		    st_b2 = st_bytes[55:48], st_b6 = st_bytes[23:16],
		    st_b3 = st_bytes[47:40], st_b7 = st_bytes[15:8],
		    st_b4 = st_bytes[39:32], st_b8 = st_bytes[7:0];
			  
wire[7:0] sdi_b1 = sdi_bytes[15:8],
			 sdi_b2 = sdi_bytes[7:0];
			  
wire[7:0] csi_b1 = csi_bytes[23:16],
	       csi_b2 = csi_bytes[15:8],
	       csi_b3 = csi_bytes[7:0];
			 
reg[4:0] regs_bytes_cntr;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		regs_bytes_cntr = 0;
	else if(CRS_ARE_READ)
		regs_bytes_cntr = 0;
	else if(rdreq)
		regs_bytes_cntr = regs_bytes_cntr + 1;
end

always@(posedge clk)
begin
	case(regs_bytes_cntr)
	0:  q = `SYS_TIME_REG_ADDR;
	1:  q = 0;
	2:  q = 8;
	3:  q = st_b1;
	4:  q = st_b2;
	5:  q = st_b3;
	6:  q = st_b4;
	7:  q = st_b5;
	8:  q = st_b6;
	9:  q = st_b7;
	10: q = st_b8;
	
	11: q = `SDI_CTRL_REG_ADDR;
	12: q = 0;
	13: q = 2; 
	14: q = sdi_b1;
	15: q = sdi_b2;
	
	16: q = `CSI_CTRL_REG_ADDR;
	17: q = 0;
	18: q = 3;
	19: q = csi_b1;
	20: q = csi_b2;
	21: q = csi_b3;
	default:
		begin
		end
	endcase
end

wire ST_LAST_BYTE  = (regs_bytes_cntr == 10),
     SDI_LAST_BYTE = (regs_bytes_cntr == 15),
	  CSI_LAST_BYTE = (regs_bytes_cntr == 21);

wire CRS_ARE_READ = CSI_LAST_BYTE;

endmodule 