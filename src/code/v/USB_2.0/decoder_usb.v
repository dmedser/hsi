module decoder_usb (
	input clk,
	input n_rst,
	input [7:0] d,
	input d_accepted,
	output [7:0] q
); 


reg[1:0] dc_state;
parameter CTRL = 0,
			 WR = 1,
			 RD_A = 2,
			 RD_D = 3;
wire DC_STATE_CTRL = (dc_state == CTRL),
	  DC_STATE_WR = (dc_state == WR),
	  DC_STATE_RD_A = (dc_state == RD_A),
	  DC_STATE_RD_D = (dc_state == RD_D);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		dc_state = CTRL;
	else
		begin
			case(dc_state)
			CTRL:
				begin
					if(d_accepted)
						dc_state = WR;
					else	
						dc_state = CTRL;
				end
			WR:
				begin
					if(FRAME_IS_CORRECT)
						begin
							dc_state = RD_A;
						end
					else	
						dc_state = WR;
				end
			RD_A:
				begin
					dc_state = RD_D;
				end
			RD_D:
				begin
					if(rd_ptr == (wr_ptr - 3))
						dc_state = CTRL;
					else 
						dc_state = RD_D;
				end
			default:
				begin
				end
			endcase
		end
end	  
			 
reg[5:0] wr_ptr;
reg[5:0] rd_ptr;

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		wr_ptr = 0;
	else if(DC_STATE_WR) 
		wr_ptr = wr_ptr + 1;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		rd_ptr = 2;
	else if (DC_STATE_RD_A)
		rd_ptr = 6;
	else if(DC_STATE_RD_D & (rd_ptr < (wr_ptr - 3)))
		rd_ptr = rd_ptr + 1;
end

crc8_atm_calc CRC8_ATM_CALC (
	.clk(clk),
	.n_rst(n_rst),
	.en(d_accepted & DC_STATE_WR),
	.d(d),
	.crc(CRC8)
);
wire[7:0] CRC8;

wire FRAME_IS_CORRECT = DC_STATE_WR & ~d_accepted & (CRC8 == 0);

wire[5:0] addr = d_accepted ? wr_ptr : rd_ptr; 

ram RX_BUF_64B (
	.address(addr),
	.clock(clk),
	.data(d),
	.rden(DC_STATE_RD_A | DC_STATE_RD_D),
	.wren(d_accepted & DC_STATE_WR),
	.q(B_Q)
);

wire[7:0] B_Q;
//5e4d010006b40102030405062f
assign q = B_Q;

			 
endmodule




