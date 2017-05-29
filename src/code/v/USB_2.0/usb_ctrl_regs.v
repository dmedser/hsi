module usb_ctrl_regs (
	input clk_ftdi,
	input clk_prj,
	input n_rst,
	input [7:0] d,
	input d_asserted,
	
	output [63:0] sys_time, 
	
	output [2:0] sdi_flags,
	output sdi_on,
	output [1:0] sdi_dat_src,
	output [1:0] sdi_com_src,
	
	output csi_btc_en,
	output csi_tm_en,
	output csi_on,
	output [1:0] csi_dat_src,
	output [1:0] csi_com_src,
	
	output [7:0] ccw_byte,
	output ccw_accepted,
	output ccw_buf_is_read,
	input  ccw_buf_rdreq,
	input  n_rst_ccw_buf_ptrs
);

`include "src/code/vh/usb_ctrl_regs_addrs.vh"

/* CSI - Collection System Imitator - Имитатор системы сбора */
/* SDI - Scientific Devise Imitator - Имитатор НА */
/* STR - System Time Register */
/* BTC - Board Time Code - КБВ */
/* CCW - Control Command Word - УКС */
/* TM  - Time Mark */

assign sys_time = STR_Q;

assign sdi_flags[0] = SDI_FLAG_SD_BUSY;
assign sdi_flags[1] = SDI_FLAG_SERVICE_REQ;
assign sdi_flags[2] = SDI_FLAG_ERR_IN_MSG;
assign sdi_on = SDI_ON;
assign sdi_dat_src = SDI_DAT_SRC;
assign sdi_com_src = SDI_COM_SRC;


assign csi_btc_en = CSI_BTC_EN;
assign csi_tm_en = CSI_TM_EN; 
assign csi_on = CSI_ON;
assign csi_dat_src = CSI_DAT_SRC;
assign csi_com_src = CSI_COM_SRC;

assign ccw_byte = CCW_BUF_Q;
assign ccw_buf_is_read = CCW_BUF_IS_READ;


reg[1:0] packer_state;
parameter CTRL = 0,
			 ADDR = 1,
			 DATA = 2;

wire PKR_STATE_CTRL = (packer_state == CTRL),
	  PKR_STATE_ADDR = (packer_state == ADDR),
	  PKR_STATE_DATA = (packer_state == DATA);
			 
always@(posedge clk_ftdi or negedge n_rst)
begin
	if(n_rst == 0)
		packer_state = CTRL;
	else
		begin
			case(packer_state)
			CTRL:
				begin
					if(d_asserted)
						packer_state = ADDR;
					else	
						packer_state = CTRL;
				end
			ADDR:
				begin
					packer_state = DATA;
				end
			DATA:
				begin
					if(~d_asserted)
						packer_state = CTRL;
					else
						packer_state = DATA;
				end
			default:
				begin
				end
			endcase
		end
end

//5e4d0c00080fa1a2a3a4a5a6a7a826 CCW



//5e4d0a0003430600007d ВКЛ метки времени и КБВ
//5e4d0a000343020000D6 ВЫКЛ КБВ 

//5e4d000008f5a1a2a3a4a5a6a7a826 СИСТЕМНОЕ ВЕРМЯ


// 5e4d0cAA0895a1a2a3a4a5a6a7a826 CCW TEST NH ненулевой

// 5e4d0800029202002a ВКЛ ФЛАГ ОШИБКИ В СООБЩЕНИИ

// 5e4d08000292000000 ОЧИСТИТЬ ВСЕ ФЛАГИ СЛЕЙВА

// 5e4d08000292040054 ВКЛ ФЛАГ ЗАПРОС НА ОБСЛУЖИВАНИЕ

//5e4d080002920800a8 ВКЛ SD_BUSY


reg_byte_en REG_BYTE_EN (
	.clk(clk_ftdi),
	.n_rst(n_rst),
	.d(d),
	.a_asserted(PKR_STATE_ADDR),
	.d_asserted(PKR_STATE_DATA),
	.reg_en(REG_EN),
	.byte_en(BYTE_EN)
);

wire[3:0] REG_EN;
wire STR_EN = REG_EN[0],
	  SDI_CR_EN = REG_EN[1], 
	  CSI_CR_EN = REG_EN[2],
	  CCW_BUF_EN = REG_EN[3];
	  
	  
wire[7:0] BYTE_EN;
wire 		 BYTE_N_1 = BYTE_EN[0];
wire[1:0] BYTE_N_2 = BYTE_EN[1:0];
wire[2:0] BYTE_N_3 = BYTE_EN[2:0];
wire[7:0] BYTE_N_8 = BYTE_EN[7:0]; 

wire[7:0] STR_BYTE_EN = BYTE_N_8;
wire[1:0] SDI_CR_BYTE_N = BYTE_N_2;
wire[2:0] CSI_CR_BYTE_N = BYTE_N_3;

sys_time_reg STR (
	.clk(clk_ftdi),
	.n_rst(n_rst),
	.d(d),
	.reg_en(STR_EN),
	.byte_en(STR_BYTE_EN),
	.q(STR_Q)
);

sdi_ctrl_reg SDI_CR (
	.clk(clk_ftdi),
	.n_rst(n_rst),
	.d(d),
	.reg_en(SDI_CR_EN),
	.byte_en(SDI_CR_BYTE_N),
	.q(SDI_CR_Q)
);

csi_ctrl_reg CSI_CR (
	.clk(clk_ftdi),
	.n_rst(n_rst),
	.d(d),
	.reg_en(CSI_CR_EN),
	.byte_en(CSI_CR_BYTE_N),
	.q(CSI_CR_Q)
);


ccw_buf CCW_BUF ( 
	.clk_ftdi(clk_ftdi),
	.clk_prj(clk_prj),
	.n_rst(n_rst),
	.wrreq(CCW_BUF_EN),
	.rdreq(ccw_buf_rdreq),
	.ccw_accepted(ccw_accepted), 
	.d(d),
	.q(CCW_BUF_Q),
	.buf_is_read(CCW_BUF_IS_READ),
	.n_rst_ptrs(n_rst_ccw_buf_ptrs)
);


wire[7:0] CCW_BUF_Q;

wire[63:0] STR_Q; 
	  
wire[15:0] SDI_CR_Q;
wire[7:0] SDI_CR_BYTE_1 = SDI_CR_Q[15:8],
			 SDI_CR_BYTE_2 = SDI_CR_Q[7:0];

wire SDI_FLAG_SD_BUSY     = SDI_CR_BYTE_1[3],
	  SDI_FLAG_SERVICE_REQ = SDI_CR_BYTE_1[2],
	  SDI_FLAG_ERR_IN_MSG  = SDI_CR_BYTE_1[1],
	  SDI_ON = SDI_CR_BYTE_1[0];

wire[1:0] SDI_DAT_SRC = SDI_CR_BYTE_2[5:4],
			 SDI_COM_SRC = SDI_CR_BYTE_2[1:0]; 


wire[23:0] CSI_CR_Q;
wire[7:0] CSI_CR_BYTE_1 = CSI_CR_Q[23:16],
			 CSI_CR_BYTE_2 = CSI_CR_Q[15:8],
			 CSI_CR_BYTE_3 = CSI_CR_Q[7:0];

wire CSI_BTC_EN = CSI_CR_BYTE_1[2],
	  CSI_TM_EN  = CSI_CR_BYTE_1[1],
	  CSI_ON     = CSI_CR_BYTE_1[0];
	 
wire[1:0] CSI_DAT_SRC = CSI_CR_BYTE_2[5:4],
			 CSI_COM_SRC = CSI_CR_BYTE_2[1:0];
			 
assign q = CSI_CR_Q; 

endmodule

module reg_byte_en (
	input clk,
	input n_rst,
	input [7:0] d,
	input a_asserted,
	input d_asserted,
	output [3:0] reg_en,
	output reg[7:0] byte_en
);

reg[7:0] addr_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		addr_reg = 0;
	else if(a_asserted)
		addr_reg = d;
end

wire N_RST_BYTE_EN = n_rst & ~a_asserted;
always@(posedge clk or negedge N_RST_BYTE_EN)
begin
	if(N_RST_BYTE_EN == 0)
		byte_en = 1;
	else if(d_asserted)
		byte_en = (byte_en << 1);
end

assign reg_en[0] = d_asserted & (addr_reg == `SYS_TIME_REG_ADDR);
assign reg_en[1] = d_asserted & (addr_reg == `SDI_CTRL_REG_ADDR);
assign reg_en[2] = d_asserted & (addr_reg == `CSI_CTRL_REG_ADDR);
assign reg_en[3] = d_asserted & (addr_reg == `CCW_BUF_ADDR);
endmodule  

module sys_time_reg (
	input clk,
	input n_rst,
	input reg_en,
	input [7:0] d,
	input [7:0] byte_en,
	output [63:0] q
);

byte_reg STR_B1 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[0]),
	.d(d),
	.q(STR_B1_Q)
);

byte_reg STR_B2 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[1]),
	.d(d),
	.q(STR_B2_Q)
);

byte_reg STR_B3 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[2]),
	.d(d),
	.q(STR_B3_Q)
);

byte_reg STR_B4 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[3]),
	.d(d),
	.q(STR_B4_Q)
);

byte_reg STR_B5 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[4]),
	.d(d),
	.q(STR_B5_Q)
);

byte_reg STR_B6 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[5]),
	.d(d),
	.q(STR_B6_Q)
);

byte_reg STR_B7 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[6]),
	.d(d),
	.q(STR_B7_Q)
);

byte_reg STR_B8 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[7]),
	.d(d),
	.q(STR_B8_Q)
);

wire[7:0] STR_B1_Q,
			 STR_B2_Q,
			 STR_B3_Q,
			 STR_B4_Q,
			 STR_B5_Q,
			 STR_B6_Q,
			 STR_B7_Q,
			 STR_B8_Q;

assign q[63:56] = STR_B1_Q;			 
assign q[55:48] =	STR_B2_Q;		 
assign q[47:40] =	STR_B3_Q;		 
assign q[39:32] =	STR_B4_Q;		 
assign q[31:24] = STR_B5_Q;			 
assign q[23:16] = STR_B6_Q; 
assign q[15:8]  = STR_B7_Q;
assign q[7:0]   = STR_B8_Q;
endmodule 

module csi_ctrl_reg (
	input clk,
	input n_rst,
	input reg_en,
	input [7:0] d,
	input [2:0] byte_en,
	output [23:0] q
);

byte_reg CSI_CR_B1 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[0]),
	.d(d),
	.q(CSI_CR_B1_Q)
);

byte_reg CSI_CR_B2 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[1]),
	.d(d),
	.q(CSI_CR_B2_Q)
);

byte_reg CSI_CR_B3 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[2]),
	.d(d),
	.q(CSI_CR_B3_Q)
);

wire[7:0] CSI_CR_B1_Q,
			 CSI_CR_B2_Q,
			 CSI_CR_B3_Q;
assign q[23:16] = CSI_CR_B1_Q; 
assign q[15:8]  = CSI_CR_B2_Q;
assign q[7:0]   = CSI_CR_B3_Q;
endmodule


module sdi_ctrl_reg (
	input clk,
	input n_rst,
	input reg_en,
	input [7:0] d,
	input [1:0] byte_en,
	output [15:0] q
);

byte_reg SDI_CR_B1 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[0]),
	.d(d),
	.q(SDI_CR_B1_Q)
);

byte_reg SDI_CR_B2 (
	.clk(clk),
	.n_rst(n_rst),
	.en(reg_en & byte_en[1]),
	.d(d),
	.q(SDI_CR_B2_Q)
);

wire[7:0] SDI_CR_B1_Q,
			 SDI_CR_B2_Q;
assign q[15:8] = SDI_CR_B1_Q; 
assign q[7:0]  = SDI_CR_B2_Q;
endmodule



module ccw_buf (
	input  clk_ftdi,
	input  clk_prj,
	input  n_rst,
	input  wrreq,
	input  rdreq,
	input  n_rst_ptrs,
	input  [7:0] d,
	output [7:0] q,
	output buf_is_read,
	output ccw_accepted
);

assign buf_is_read = (rd_ptr == usedw);

reg wrreq_sync;
always@(posedge clk_prj or negedge n_rst)
begin
	if(n_rst == 0)
		wrreq_sync = 0;
	else
		wrreq_sync = wrreq;
end

wire TICK_AFTER_WRREQ = ~wrreq & wrreq_sync;
assign ccw_accepted = TICK_AFTER_WRREQ;

reg[5:0] wr_ptr,
			rd_ptr;
			
wire N_RST_PTRS = n_rst & n_rst_ptrs;			
always@(posedge clk_ftdi or negedge N_RST_PTRS)
begin
	if(N_RST_PTRS == 0)
		wr_ptr = 0;
	else if(wrreq)
		wr_ptr = wr_ptr + 1;
end

reg[5:0] usedw;
always@(posedge clk_ftdi or negedge n_rst)
begin
	if(n_rst == 0)
		usedw = 0;
	else if(wr_ptr == 1)
		usedw = d[5:0] + 2;
end

always@(posedge clk_prj or negedge N_RST_PTRS)
begin
	if(N_RST_PTRS == 0)
		rd_ptr = 0;
	else if(rdreq)
		rd_ptr = rd_ptr + 1;
end

wire[5:0] addr = wrreq ? wr_ptr : rd_ptr; 
			
ram_64B RAM_64B (
	.inclock(clk_ftdi),
	.outclock(clk_prj),
	.address(addr),
	.data(d),
	.wren(wrreq),
	.rden(rdreq),
	.q(q)
);
endmodule 


module byte_reg (
	input clk,
	input n_rst,
	input en,
	input [7:0] d,
	output reg[7:0] q
);
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0) q = 0;
	else if(en)    q = d;
end

endmodule 