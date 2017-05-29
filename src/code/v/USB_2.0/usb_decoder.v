module usb_decoder (
	input clk,
	input n_rst,
	input [7:0] d,
	input d_asserted,
	output [7:0] q,
	output reg q_asserted
); 

`include "src/code/vh/usb_ctrl_regs_addrs.vh"

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
					if(d_asserted)
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


reg[6:0] byte_cntr;			 
reg[6:0] wr_ptr;
reg[6:0] rd_ptr;

always@(posedge clk or negedge N_RST_DECODER)
begin
	if(N_RST_DECODER == 0)
		byte_cntr = 0;
	else if(DC_STATE_WR) 
		byte_cntr = byte_cntr + 1;
end

wire ADDR_BYTE   = (byte_cntr == 2);
wire NH_NL_BYTES = ((byte_cntr > 2) & (byte_cntr < 5));
wire DATA_BYTES  = (byte_cntr > 5);

wire CURRENT_FRAME_IS_CCW = DC_STATE_WR & ADDR_BYTE & (d == `CCW_BUF_ADDR);

reg N_WR_EN;
always@(posedge clk or negedge N_RST_DECODER)
begin
	if(N_RST_DECODER == 0)
		N_WR_EN = 0;
	else if(CURRENT_FRAME_IS_CCW)
		N_WR_EN = 1;
end

wire WR_PTR_INCR_EN = DC_STATE_WR & (N_WR_EN ? (ADDR_BYTE | NH_NL_BYTES | DATA_BYTES) : (ADDR_BYTE | DATA_BYTES)); 

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
	.en(d_asserted & DC_STATE_WR),
	.d(d),
	.crc(CRC8)
);
wire[7:0] CRC8;


wire FRAME_END = DC_STATE_WR & ~d_asserted;
wire FRAME_IS_CORRECT = (CRC8 == 0);

wire[6:0] addr = d_asserted ? wr_ptr : rd_ptr; 

ram_128B RX_BUF_128B (
	.address(addr),
	.clock(clk),
	.data(d),
	.rden(DC_STATE_RD),
	.wren(d_asserted & WR_PTR_INCR_EN),
	.q(RX_BUF_Q)
);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		q_asserted = 0;
	else 
		q_asserted = DC_STATE_RD;
end

wire[7:0] RX_BUF_Q;
assign q = RX_BUF_Q;

			 
endmodule




