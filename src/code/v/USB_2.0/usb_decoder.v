module usb_decoder (
	input clk,
	input n_rst,
	input [7:0] d,
	input d_accepted,
	output [7:0] q,
	output reg q_accepted
); 


reg[1:0] dc_state;
parameter CTRL = 0,
			 WR = 1,
			 RD = 2;
			 
wire DC_STATE_CTRL = (dc_state == CTRL),
	  DC_STATE_WR = (dc_state == WR),
	  DC_STATE_RD = (dc_state == RD);

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
					if(FRAME_END)
						begin
							if(FRAME_IS_CORRECT)
								dc_state = RD;
							else
								dc_state = CTRL;
						end
					else	
						dc_state = WR;
				end
			RD:
				begin
					if(rd_ptr == (wr_ptr - 3))
						dc_state = CTRL;
					else 
						dc_state = RD;
				end
			default:
				begin
				end
			endcase
		end
end	  


reg[5:0] byte_cntr;			 
reg[5:0] wr_ptr;
reg[5:0] rd_ptr;

always@(posedge clk or negedge N_RST_DECODER)
begin
	if(N_RST_DECODER == 0)
		byte_cntr = 0;
	else if(DC_STATE_WR) 
		byte_cntr = byte_cntr + 1;
end

wire WR_PTR_INCR_EN = DC_STATE_WR & ((byte_cntr == 2) | (byte_cntr > 5)); 

wire N_RST_DECODER = n_rst & ~DC_STATE_CTRL;

always@(posedge clk or negedge N_RST_DECODER)
begin
	if(N_RST_DECODER == 0)
		wr_ptr = 0;
	else if(WR_PTR_INCR_EN) 
		wr_ptr = wr_ptr + 1;
end

always@(posedge clk or negedge N_RST_DECODER)
begin
	if(N_RST_DECODER == 0)
		rd_ptr = 0;
	else if(DC_STATE_RD)
		rd_ptr = rd_ptr + 1;
end

crc8_atm_calc CRC8_ATM_CALC (
	.clk(clk),
	.n_rst(N_RST_DECODER),
	.en(d_accepted & DC_STATE_WR),
	.d(d),
	.crc(CRC8)
);
wire[7:0] CRC8;


wire FRAME_END = DC_STATE_WR & ~d_accepted;
wire FRAME_IS_CORRECT = (CRC8 == 0);

wire[5:0] addr = d_accepted ? wr_ptr : rd_ptr; 

ram RX_BUF_64B (
	.address(addr),
	.clock(clk),
	.data(d),
	.rden(DC_STATE_RD),
	.wren(d_accepted & WR_PTR_INCR_EN),
	.q(B_Q)
);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		q_accepted = 0;
	else if(DC_STATE_RD)
		q_accepted = 1;
	else
		q_accepted = 0;
end

wire[7:0] B_Q;
//5e4d010006b40102030405062f
assign q = B_Q;

			 
endmodule




