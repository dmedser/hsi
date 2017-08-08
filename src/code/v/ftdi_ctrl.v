module ftdi_ctrl (
	input   clk,
	input   n_rst,
	output  oe,
	input   rxf,
	output  rd,
	output  wr,
	inout   [7:0] dq,
	input   [7:0] d,
	input   d_asserted,
	output  [7:0] q
);
assign wr = ~d_asserted;

assign dq = oe ? d : 8'hZZ;	
assign q = oe ? 0 : dq;

wire READ_PREPARE = (fc_state == FC_STATE_READ_PREPARE),
	  READ	      = (fc_state == FC_STATE_READ);
	  
reg [1:0] fc_state;
parameter FC_STATE_CTRL 		  = 0, 
			 FC_STATE_READ_PREPARE = 1,
			 FC_STATE_READ			  = 2;			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		fc_state = FC_STATE_CTRL;
	else 
		begin
			case(fc_state)
				FC_STATE_CTRL:
					begin
						if(~rxf & ~d_asserted)
							fc_state = FC_STATE_READ_PREPARE;
						else
							fc_state = FC_STATE_CTRL;
					end
				FC_STATE_READ_PREPARE:
					begin
						fc_state = FC_STATE_READ;
					end
				FC_STATE_READ:
					begin
						if(rxf)
							fc_state = FC_STATE_CTRL;
						else 
							fc_state = FC_STATE_READ;
					end
				default: 	
					begin
						fc_state = FC_STATE_CTRL;
					end
			endcase
		end
end

assign oe = ~(READ_PREPARE | READ);
assign rd = ~READ;


endmodule 