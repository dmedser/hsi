module ftdi_ctrl (
	input   clk,
	input   n_rst,
	output  oe,
	input   rxf,
	input   rd_en,
	input   cd_busy,
	output  reg byte_hold,
	output  rd,
	input   txe,
	output  wr,
	inout   [7:0] dq,
	input   [7:0] d,
	output  [7:0] q
);
assign wr = 1;
assign dq = oe ? d : 8'hZZ;	

wire READ_PREPARE = (fc_state == FC_STATE_READ_PREPARE),
	  READ_BYTE    = (fc_state == FC_STATE_READ_BYTE);
	  
reg [1:0] fc_state;
parameter FC_STATE_CTRL 		  = 0, 
			 FC_STATE_READ_PREPARE = 1,
			 FC_STATE_READ_BYTE	  = 2,
			 FC_STATE_WRITE		  = 3;			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		fc_state = FC_STATE_CTRL;
	else 
		begin
			case(fc_state)
				FC_STATE_CTRL:
					begin
						if(~rxf & byte_rd_en)
							fc_state = FC_STATE_READ_PREPARE;
						else
							fc_state = FC_STATE_CTRL;
					end
				FC_STATE_READ_PREPARE:
					begin
						fc_state = FC_STATE_READ_BYTE;
					end
				FC_STATE_READ_BYTE:
					begin
						fc_state = FC_STATE_CTRL;
					end
				FC_STATE_WRITE:
					begin
					
					end
				default: 	
					begin
					end
			endcase
		end
end

assign oe = ~(READ_PREPARE | READ_BYTE);
assign rd = ~READ_BYTE;

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		byte_hold = 0;
	else if(rd_en)
		begin
			if(rd == 0)
				byte_hold = 1;
			else if(cd_busy)
				byte_hold = 0;
		end
	else if(cd_busy) 
		byte_hold = 0;
end
wire byte_rd_en = rd_en & ~cd_busy & ~byte_hold;

reg[7:0] d_from_usb;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		d_from_usb = 0;
	else if(rd == 0)
		d_from_usb = dq;
end

assign q = d_from_usb;
endmodule 