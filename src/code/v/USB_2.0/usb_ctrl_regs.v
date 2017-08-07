module usb_ctrl_regs (
	input clk_ftdi,
	input n_rst,
	
	input [7:0] d,
	input d_asserted,
	
	output [15:0] sdi_bytes,
	output [23:0] csi_bytes,
	
	inout [15:0] st_day,
	inout [26:0] st_ms_of_day,
	inout [9:0]  st_us_of_ms,
	
	//input st_update_disable,
	
	output [63:0] st_bytes,
	
	input  st_tim_100ms_wrreq,
	output st_preset,
	
	output [7:0] ccw_byte,
	output ccw_accepted,
	output ccwb_is_read,
	input  ccwb_rdreq
);

`include "src/code/vh/usb_ctrl_regs_addrs.vh"

/* CSI - Collection System Imitator - Имитатор системы сбора */
/* SDI - Scientific Devise Imitator - Имитатор НА */
/* STR - System Time Register */
/* BTC - Board Time Code - КБВ */
/* CCW - Control Command Word - УКС */
/* TM  - Time Mark */

assign sdi_bytes[15:8] = SDI_CR_BYTE_1;
assign sdi_bytes[7:0] = SDI_CR_BYTE_2;

assign csi_bytes[23:16] = CSI_CR_BYTE_1;
assign csi_bytes[15:8] = CSI_CR_BYTE_2;
assign csi_bytes[7:0] = CSI_CR_BYTE_3;


assign ccw_byte = CCW_BUF_Q;
assign ccwb_is_read = CCW_BUF_IS_READ;	

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

// 5e4d000008f5000000000000000000 RESET_SYS_TIM 

// 5e4d0cAA0895a1a2a3a4a5a6a7a826 CCW TEST NH ненулевой

// 5e4d0800029202002a ВКЛ ФЛАГ ОШИБКИ В СООБЩЕНИИ

// 5e4d08000292000000 ОЧИСТИТЬ ВСЕ ФЛАГИ СЛЕЙВА

// 5e4d08000292040054 ВКЛ ФЛАГ ЗАПРОС НА ОБСЛУЖИВАНИЕ
// 5e4d0800029205338cab




// 5e4d080002920800a8 ВКЛ SD_BUSY

// 5e4d08000292003399 ВКЛЮЧИТЬ ВСЕ ЛИННИ ДАННЫХ И ЛИНИИ КОМАНД ДЛЯ СЛЕЙВА

// 5e4d0a000343063300bb ВКЛЮЧИТЬ КБВ МЕТКИ ВРЕМЕНИ И ВСЕ ЛИНИИ ДАННЫХ И КОМАНД ДЛЯ МАСТЕРА

// 5e4d0a000343073300d0 НОРМАЛЬНАЯ РАБОТА МАСТЕРА
 
// 5e4d0800029201338c НОРМАЛЬНАЯ РАБОТА СЛЕЙВА 

 
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
	
	.usb_wrreq(STR_EN),
	.tim_wrreq(st_tim_100ms_wrreq),
	.st_preset(st_preset),
	
	.byte_en(BYTE_N_8),
	.d(d),
	
	.day(st_day),
	.ms_of_day(st_ms_of_day),
	.us_of_ms(st_us_of_ms),
	
	
	.q(st_bytes)
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
	.n_rst(n_rst),
	.wrreq(CCW_BUF_EN),
	.rdreq(ccwb_rdreq),
	.ccw_accepted(ccw_accepted), 
	.d(d),
	.q(CCW_BUF_Q),
	.buf_is_read(CCW_BUF_IS_READ)
);


wire[7:0] CCW_BUF_Q;
	  
wire[15:0] SDI_CR_Q;
wire[7:0] SDI_CR_BYTE_1 = SDI_CR_Q[15:8],
			 SDI_CR_BYTE_2 = SDI_CR_Q[7:0];

wire[23:0] CSI_CR_Q;
wire[7:0] CSI_CR_BYTE_1 = CSI_CR_Q[23:16],
			 CSI_CR_BYTE_2 = CSI_CR_Q[15:8],
			 CSI_CR_BYTE_3 = CSI_CR_Q[7:0];

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
	
	input usb_wrreq,
	input tim_wrreq,
	
	input [7:0] byte_en,
	input [7:0] d,
	
	output st_preset,
	
	inout [15:0] day,
	inout [26:0] ms_of_day,
	inout [9:0]  us_of_ms,
	
	output [63:0] q
);

wire ANY_WRREQ = usb_wrreq | tim_wrreq;

reg usb_wrreq_sync;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		usb_wrreq_sync = 0;
	else 
		usb_wrreq_sync = usb_wrreq;
end

wire TICK_AFTER_USB_WRREQ = ~usb_wrreq & usb_wrreq_sync;

assign st_preset = TICK_AFTER_USB_WRREQ;

byte_mx B_MX1 (
	.select(tim_wrreq),
	.b_in1(day[15:8]),
	.b_in2(d),
	.b_out(B_MX1_Q)
);
wire [7:0] B_MX1_Q;

byte_reg STR_B1 (
	.clk(clk),
	.n_rst(n_rst),
	.en((usb_wrreq & byte_en[0]) | tim_wrreq),
	.d(B_MX1_Q),
	.q(B1)
);

byte_mx B_MX2 (
	.select(tim_wrreq),
	.b_in1(day[7:0]),
	.b_in2(d),
	.b_out(B_MX2_Q)
);
wire [7:0] B_MX2_Q;


byte_reg STR_B2 (
	.clk(clk),
	.n_rst(n_rst),
	.en((usb_wrreq & byte_en[1]) | tim_wrreq),
	.d(B_MX2_Q),
	.q(B2)
);


byte_mx B_MX3 (
	.select(tim_wrreq),
	.b_in1(ms_of_day[26:24]),
	.b_in2(d),
	.b_out(B_MX3_Q)
);
wire [7:0] B_MX3_Q;

byte_reg STR_B3 (
	.clk(clk),
	.n_rst(n_rst),
	.en((usb_wrreq & byte_en[2]) | tim_wrreq),
	.d(B_MX3_Q),
	.q(B3)
);


byte_mx B_MX4 (
	.select(tim_wrreq),
	.b_in1(ms_of_day[23:16]),
	.b_in2(d),
	.b_out(B_MX4_Q)
);
wire [7:0] B_MX4_Q;

byte_reg STR_B4 (
	.clk(clk),
	.n_rst(n_rst),
	.en((usb_wrreq & byte_en[3]) | tim_wrreq),
	.d(B_MX4_Q),
	.q(B4)
);


byte_mx B_MX5 (
	.select(tim_wrreq),
	.b_in1(ms_of_day[15:8]),
	.b_in2(d),
	.b_out(B_MX5_Q)
);
wire [7:0] B_MX5_Q;


byte_reg STR_B5 (
	.clk(clk),
	.n_rst(n_rst),
	.en((usb_wrreq & byte_en[4]) | tim_wrreq),
	.d(B_MX5_Q),
	.q(B5)
);


byte_mx B_MX6 (
	.select(tim_wrreq),
	.b_in1(ms_of_day[7:0]),
	.b_in2(d),
	.b_out(B_MX6_Q)
);
wire [7:0] B_MX6_Q;


byte_reg STR_B6 (
	.clk(clk),
	.n_rst(n_rst),
	.en((usb_wrreq & byte_en[5]) | tim_wrreq),
	.d(B_MX6_Q),
	.q(B6)
);


byte_mx B_MX7 (
	.select(tim_wrreq),
	.b_in1(us_of_ms[9:8]),
	.b_in2(d),
	.b_out(B_MX7_Q)
);
wire [7:0] B_MX7_Q;


byte_reg STR_B7 (
	.clk(clk),
	.n_rst(n_rst),
	.en((usb_wrreq & byte_en[6]) | tim_wrreq),
	.d(B_MX7_Q),
	.q(B7)
);


byte_mx B_MX8 (
	.select(tim_wrreq),
	.b_in1(us_of_ms[7:0]),
	.b_in2(d),
	.b_out(B_MX8_Q)
);
wire [7:0] B_MX8_Q;

byte_reg STR_B8 (
	.clk(clk),
	.n_rst(n_rst),
	.en((usb_wrreq & byte_en[7]) | tim_wrreq),
	.d(B_MX8_Q),
	.q(B8)
);

wire[7:0] B1,
			 B2,
			 B3,
			 B4,
			 B5,
			 B6,
			 B7,
			 B8;	 

assign b1 = B1;
assign b2 = B2;
assign b3 = B3;
assign b4 = B4;

assign b5 = B5;			 
assign b6 = B6;
assign b7 = B7;
assign b8 = B8;

assign day[15:8] = st_preset ? B1 : 8'hZZ;
assign day[7:0]  = st_preset ? B2 : 8'hZZ;

assign ms_of_day[26:24] = st_preset ? B3[2:0] : 3'hZZ;
assign ms_of_day[23:16] = st_preset ? B4 : 8'hZZ;
assign ms_of_day[15:8]  = st_preset ? B5 : 8'hZZ;
assign ms_of_day[7:0]   = st_preset ? B6 : 8'hZZ;

assign us_of_ms[9:8]  = st_preset? B7[1:0] : 2'hZZ;
assign us_of_ms[7:0]	 = st_preset? B8 : 8'hZZ;	

assign q[63:56] = B1;
assign q[55:48] = B2;
assign q[47:40] = B3;
assign q[39:32] = B4;

assign q[31:24] = B5;
assign q[23:16] = B6;
assign q[15:8] = B7;
assign q[7:0] = B8;
endmodule 


module byte_mx (
	input select,
	input [7:0] b_in1,
	input [7:0] b_in2,
	output [7:0] b_out
);
assign b_out = select ? b_in1 : b_in2;
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
	input  n_rst,
	input  wrreq,
	input  rdreq,
	input  [7:0] d,
	output [7:0] q,
	output reg buf_is_read,
	output ccw_accepted
);

assign q = (rd_ptr == 1) ? `CCW_BUF_ADDR : RAM_64B_Q;

always@(posedge clk_ftdi or negedge n_rst)
begin
	if(n_rst == 0)
		buf_is_read = 0;
	else
		buf_is_read = rdreq & (rd_ptr == (usedw - 1));
end


reg wrreq_sync;
always@(posedge clk_ftdi or negedge n_rst)
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

			
wire N_RST_PTRS = n_rst & ~rst_ptrs_after_buf_is_read;			
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

always@(posedge clk_ftdi or negedge N_RST_PTRS)
begin
	if(N_RST_PTRS == 0)
		rd_ptr = 0;
	else if(rdreq)
		rd_ptr = rd_ptr + 1;
end

reg buf_is_read_sync;
always@(posedge clk_ftdi or negedge n_rst)
begin
	if(n_rst == 0)
		buf_is_read_sync = 0;
	else 
		buf_is_read_sync = buf_is_read;
end

wire TICK_AFTER_BUF_IS_READ = ~buf_is_read & buf_is_read_sync;

reg rst_ptrs_after_buf_is_read;
always@(posedge clk_ftdi or negedge n_rst)
begin
	if(n_rst == 0)
		rst_ptrs_after_buf_is_read = 0;
	else 
		rst_ptrs_after_buf_is_read = TICK_AFTER_BUF_IS_READ;
end

wire[5:0] addr = wrreq ? wr_ptr : rd_ptr; 
			
ram_64B RAM_64B (
	.clock(clk_ftdi),
	.address(addr),
	.data(d),
	.wren(wrreq),
	.rden(rdreq),
	.q(RAM_64B_Q) 
);

wire[7:0] RAM_64B_Q;
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


module byte_reg_al (
	input clk,
	input n_rst,
	input aload,
	input en,
	input [7:0] d,
	output reg[7:0] q
);
always@(posedge clk or negedge n_rst or posedge aload)
begin
	if(n_rst == 0) q = 0;
	else if(aload) q = d;
	else if(en)    q = d;
end
endmodule