module ftdi_ctrl (
	input   clk,
	input   n_rst,
	output  oe,
	input   rxf,
	output  rd,
	
	output  ccw_accepted,
	output  sd_d_accepted,
	output  reg sd_busy,

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
						if(~rxf)
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
						if(rxf)
							fc_state = FC_STATE_CTRL;
						else 
							fc_state = FC_STATE_READ_BYTE;
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

parameter ID_CCW = 1,
			 ID_SD_D  = 2,
			 SET_SD_BUSY = 8'h13,
			 CLR_SD_BUSY = 8'h03;
			 
assign ccw_accepted = ~rd & (dq == ID_CCW);
assign sd_d_accepted  = ~rd & (dq == ID_SD_D);


wire set_sd_busy = ~rd & (dq == SET_SD_BUSY),
	  clr_sd_busy = ~rd & (dq == CLR_SD_BUSY);
	  
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		sd_busy = 0;
	else if(set_sd_busy | clr_sd_busy)
		sd_busy = dq[4];
end

endmodule 