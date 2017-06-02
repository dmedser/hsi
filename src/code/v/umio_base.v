module umio_base (

/*********************** CLK **********************/
		
		input CLK_24,

/******************* SDRAM DD33 *******************/

		output [12:0] SDRAM_A,
		output [1:0]  SDRAM_BA,
		output SDRAM_CLK,
		output SDRAM_CLKE,
		output SDRAM_nCS,
		output SDRAM_DQMH,
		inout  [15:0] SDRAM_DQ,
		output SDRAM_nRAS,
		output SDRAM_nCAS,
		output SDRAM_nWE,
		output SDRAM_DQML,

/********************** TP X1 **********************/

		output wire [6:1] TP, 
	
/******************** FTDI DD31 ********************/	
		
		output FUSB_nRES,
		inout  [7:0] FU_D, 
		input  FRXF,
		input  FPWREN,
		output FODD,
		output FOE,
		output FSIWU,
		output FWR,
		output FRD,
		input  FTXE,
		input  FCLK_OUT,
		
		
/********************* I2C DD3 *********************/	
		
		inout   FSDA,
		output  FSCL,
				
/****************************************************/	
	
	// DD5
		input   FH3_D1_R,
		output  FH3_D1_D,
		output  FH3_D1_nRE,
		output  FH3_D1_DE, //
	// DD6 
		input   FL2_D1_R,
		output  FL2_D1_D,
		output  FL2_D1_nRE,
		output  FL2_D1_DE, //
	// DD7
		input   FH1_D1_R,
		output  FH1_D1_D,
		output  FH1_D1_nRE,
		output  FH1_D1_DE, // 
	// DD8
		input	  FH2_D1_R, 
		output  FH2_D1_D,
		output  FH2_D1_nRE,
		output  FH2_D1_DE, //
	// DD9
		input   FH3_C1_R,
		output  FH3_C1_D,
		output  FH3_C1_nRE,
		output  FH3_C1_DE, //
	// DD10
		input   FL2_D2_R,
		output  FL2_D2_D,
		output  FL2_D2_nRE,
		output  FL2_D2_DE, //
	// DD11
		input   FH1_C1_R,
		output  FH1_C1_D,
		output  FH1_C1_nRE,
		output  FH1_C1_DE, //
	// DD12
		input   FH2_C1_R,
		output  FH2_C1_D,
		output  FH2_C1_nRE,
		output  FH2_C1_DE, //
	// DD13
		input   FH3_D2_R,
		output  FH3_D2_D,
		output  FH3_D2_nRE,
		output  FH3_D2_DE, //
	// DD14 	
		input   FL1_D1_R,  
		output  FL1_D1_D,
		output  FL1_D1_nRE,
		output  FL1_D1_DE, //
	// DD15
		input   FH1_D2_R,
		output  FH1_D2_D,
		output  FH1_D2_nRE,
		output  FH1_D2_DE, //
	// DD16
		input	  FH2_D2_R, 
		output  FH2_D2_D,
		output  FH2_D2_nRE,
		output  FH2_D2_DE, //
	// DD17
		input   FH3_C2_R,
		output  FH3_C2_D,
		output  FH3_C2_nRE,
		output  FH3_C2_DE, //
	// DD18
		input   FL1_D2_R,
		output  FL1_D2_D,
		output  FL1_D2_nRE,
		output  FL1_D2_DE, //
	// DD19
		input	  FH1_C2_R,
		output  FH1_C2_D,
		output  FH1_C2_nRE,
		output  FH1_C2_DE, //
	// DD20
		input   FH2_C2_R,
		output  FH2_C2_D,
		output  FH2_C2_nRE,
		output  FH2_C2_DE, //	
	// DD21
		input   FH4_D1_R,
		output  FH4_D1_D,
		output  FH4_D1_nRE,
		output  FH4_D1_DE, //
	// DD22
		input   FH4_C1_R,
		output  FH4_C1_D,
		output  FH4_C1_nRE,
		output  FH4_C1_DE, //
	// DD23
		input   FL3_D1_R,
		output  FL3_D1_D,
		output  FL3_D1_nRE,
		output  FL3_D1_DE, //
	// DD24
		input   FH4_D2_R,
		output  FH4_D2_D,
		output  FH4_D2_nRE,
		output  FH4_D2_DE, //
	// DD25
		input   FL3_D2_R,
		output  FL3_D2_D,
		output  FL3_D2_nRE,
		output  FL3_D2_DE, //
	// DD26
		input   FH4_C2_R,		
		output  FH4_C2_D,
		output  FH4_C2_nRE,
		output  FH4_C2_DE //
		
);

/********** SDRAM **********/

assign SDRAM_A  	= 0;
assign SDRAM_BA 	= 0;
assign SDRAM_CLK	 = 0;
assign SDRAM_CLKE  = 0;
assign SDRAM_nCS 	 = 1;
assign SDRAM_DQMH  = 0;
assign SDRAM_DQ 	 = 0;
assign SDRAM_nRAS	 = 1;
assign SDRAM_nCAS	 = 1;
assign SDRAM_nWE	 = 1;
assign SDRAM_DQML	 = 0;

/************ TP ************/

assign TP[6:1] = 0;

/*********** FTDI ***********/

assign FUSB_nRES = 1;
assign FODD		  = 1;
assign FSIWU	  = 1;

/************ I2C ************/

assign FSDA = 0;
assign FSCL = 0;

/*****************************/

assign FH3_D1_D 	= DAT1;
assign FH3_D1_nRE = 1;
assign FH3_D1_DE 	= 1;

assign FL2_D1_D	= 0;
assign FL2_D1_nRE = 1;
assign FL2_D1_DE  = 0; 
  
assign FH1_D1_D	= COM1;
assign FH1_D1_nRE	= 1;
assign FH1_D1_DE	= 1;

assign FH2_D1_D	= COM2;
assign FH2_D1_nRE	= 1;
assign FH2_D1_DE	= 1;

assign FH3_C1_D	= 0;	
assign FH3_C1_nRE	= 1;
assign FH3_C1_DE	= 0;

assign FL2_D2_D	= 0;
assign FL2_D2_nRE	= 1;
assign FL2_D2_DE	= 0;

assign FH1_C1_D	= 0;
assign FH1_C1_nRE	= 1;
assign FH1_C1_DE	= 0;
		
assign FH2_C1_D	= 0;
assign FH2_C1_nRE	= 1;
assign FH2_C1_DE	= 0;

assign FH3_D2_D	= 0;
assign FH3_D2_nRE	= 1;
assign FH3_D2_DE	= 0;

assign FL1_D1_D	= 0;
assign FL1_D1_nRE	= 1;
assign FL1_D1_DE	= 0;	
		
assign FH1_D2_D	= DAT2;
assign FH1_D2_nRE	= 1;
assign FH1_D2_DE	= 1;

assign FH2_D2_D	= 0;
assign FH2_D2_nRE	= 1;
assign FH2_D2_DE	= 0;

assign FH3_C2_D	= 0;
assign FH3_C2_nRE	= 1;
assign FH3_C2_DE	= 0;

assign FL1_D2_D	= 0;
assign FL1_D2_nRE	= 1;
assign FL1_D2_DE	= 0;

assign FH1_C2_D	= 0;
assign FH1_C2_nRE	= 1;
assign FH1_C2_DE	= 0;

assign FH2_C2_D	= 0;
assign FH2_C2_nRE	= 1;
assign FH2_C2_DE	= 0;

assign FH4_D1_D	= 0;
assign FH4_D1_nRE	= 1;
assign FH4_D1_DE	= 0;

assign FH4_C1_D	= 0;
assign FH4_C1_nRE	= 1;
assign FH4_C1_DE	= 0;

assign FL3_D1_D	= 0;
assign FL3_D1_nRE	= 1;
assign FL3_D1_DE	= 0;

assign FH4_D2_D	= 0;
assign FH4_D2_nRE	= 1;
assign FH4_D2_DE	= 0;

assign FL3_D2_D	= 0;
assign FL3_D2_nRE	= 1;
assign FL3_D2_DE	= 0;

assign FH4_C2_D	= 0;
assign FH4_C2_nRE	= 1;
assign FH4_C2_DE	= 0;

/********************  MODULES ********************/

pll PLL(
	.inclk0(CLK_24),
	.c0(CLK_48),
	.c1(STP_CLK_1x8_8),
	.c2(STP_CLK_48x4_192),
	.c3(STP_CLK_60x4_240)
);

reset_controller RST_CTRL (
	.clk(CLK_48),
	.n_rst(N_RST)
);

hsi_master HSI_MSTR(
	.clk(CLK_48),
	.n_rst(N_RST),
	
	.en(USB_CSI_ON),
	
	.sdreq_en(1),
	.sr_tx_rdy(SR_TX_RDY),
	.sr_tx_ack(SR_TX_ACK),
	.sr_repeat_req(SR_REPEAT_REQ),
	
	.tm_en(USB_CSI_TM_EN),
	.tm_tx_rdy(TM_TX_RDY),
	.tm_tx_ack(TM_TX_ACK),
	.pre_tm(PRE_TM),
	
	.btc_en(USB_CSI_BTC_EN),
	.btc(40'hABCDEF1122),
	
	.ccw_accepted(CCW_ACCEPTED),
	.ccw_tx_rdy(CCW_TX_RDY),
	.ccw_rx_rdy(CCW_RX_RDY),
	.ccw_byte(CCW_BYTE),
	.ccw_repeat_req(CCW_REPEAT_REQ),
	
	
	.base_com(0),
	.com_en(USB_CSI_COM_EN),
	
	.dat_src(0),
	.dat_en(USB_CSI_DAT_EN),
	
	.q(),

	.com1(COM1),
	.com2(COM2),
	.dat1(DAT1),
	.dat2(DAT2)
);


tm_sr_gen TM_SR_GEN(
	.clk(CLK_48),
	.n_rst(N_RST),
	.tm_tx_rdy(TM_TX_RDY),
	.tm_tx_ack(TM_TX_ACK),
	.sr_tx_rdy(SR_TX_RDY),
	.sr_tx_ack(SR_TX_ACK),
	.sr_repeat_req(SR_REPEAT_REQ),
	.pre_tm(PRE_TM),
	.l00_ms_is_left(l00_MS_IS_LEFT)
);

ftdi_ctrl FTDI_CTRL (
	.clk(FCLK_OUT),
	.n_rst(N_RST),
	.oe(FOE),
	.rxf(FRXF),
	.rd(FRD),
	.txe(FTXE),
	.wr(FWR),
	.dq(FU_D),
	.d(),
	.q(FTDI_Q)
);
wire[7:0] FTDI_Q;

usb_decoder USB_DC (
	.clk(FCLK_OUT),
	.n_rst(N_RST),
	.d(FTDI_Q),
	.d_asserted(~(FOE | FRXF)),
	.q(USB_DC_Q),
	.q_asserted(USB_DC_Q_ASSERTED)
);

usb_ctrl_regs USB_CTRL_REGS (
	.clk_ftdi(FCLK_OUT),
	.clk_prj(CLK_48),
	.n_rst(N_RST),
	.d(USB_DC_Q),
	.d_asserted(USB_DC_Q_ASSERTED),
	
	
	.st_day(ST_DAY),
	.st_ms_of_day(ST_MS_OF_DAY),
	.st_us_of_ms(ST_US_OF_MS),
	
	.st_bytes(ST_BYTES),
	
	.st_tim_100ms_wrreq(l00_MS_IS_LEFT),
	.st_preset(ST_PRESET),
	
	.sdi_bytes(SDI_BYTES),
	
	.csi_bytes(CSI_BYTES),
	
	.ccw_byte(CCW_BYTE),
	.ccw_accepted(CCW_ACCEPTED),
	.ccw_buf_is_read(CCW_BUF_IS_READ),
	.ccw_buf_rdreq(CCW_BUF_RDREQ),
	.n_rst_ccw_buf_ptrs(N_RST_CCW_BUF_PTRS)
);


system_timer SYS_TIM (
	.clk(FCLK_OUT),
	.n_rst(N_RST),
	.preset(ST_PRESET),
	
	.day(ST_DAY),
	.ms_of_day(ST_MS_OF_DAY),
	.us_of_ms(ST_US_OF_MS)	
);

wire[63:0] ST_BYTES; 
wire[15:0] SDI_BYTES;
wire[23:0] CSI_BYTES;

wire[7:0] ST_B1 = ST_BYTES[63:56],
			 ST_B2 = ST_BYTES[55:48],
			 ST_B3 = ST_BYTES[47:40],
			 ST_B4 = ST_BYTES[39:32],
			 ST_B5 = ST_BYTES[31:24],
			 ST_B6 = ST_BYTES[23:16],
			 ST_B7 = ST_BYTES[15:8],
			 ST_B8 = ST_BYTES[7:0];

wire[15:0] ST_DAY;
wire[26:0] ST_MS_OF_DAY;
wire[9:0]  ST_US_OF_MS;

wire ST_PRESET;

wire[7:0] SDI_B1 = SDI_BYTES[15:8],
			 SDI_B2 = SDI_BYTES[7:0];

wire USB_SDI_FLAG_SD_BUSY     = SDI_B1[3],
	  USB_SDI_FLAG_SERVICE_REQ = SDI_B1[2],
	  USB_SDI_FLAG_ERR_IN_MSG  = SDI_B1[1],
	  USB_SDI_ON = SDI_B1[0];

wire[1:0] USB_SDI_DAT_EN = SDI_B2[5:4],
			 USB_SDI_COM_EN = SDI_B2[1:0]; 
			 
			 
wire[7:0] CSI_B1 = CSI_BYTES[23:16],
			 CSI_B2 = CSI_BYTES[15:8],
			 CSI_B3 = CSI_BYTES[7:0];

wire USB_CSI_BTC_EN = CSI_B1[2],
	  USB_CSI_TM_EN  = CSI_B1[1],
	  USB_CSI_ON     = CSI_B1[0];
	 
wire[1:0] USB_CSI_DAT_EN = CSI_B2[5:4],
			 USB_CSI_COM_EN = CSI_B2[1:0];

wire[63:0] SYS_TIME;

wire[7:0] USB_DC_Q;
wire USB_DC_Q_ACCEPTED;

wire [7:0] CCW_BYTE;
wire CCW_ACCEPTED,
	  CCW_BUF_IS_READ,
	  CCW_BUF_RDREQ;
	  
	  
usb_ccw_ctrl USB_CCW_CTRL (
	.clk(CLK_48),
	.n_rst(N_RST),
	.ccw_accepted(CCW_ACCEPTED),
	.ccw_tx_rdy(CCW_TX_RDY),
	.ccw_rx_rdy(CCW_RX_RDY),
	.ccw_buf_rdreq(CCW_BUF_RDREQ),
	.ccw_buf_is_read(CCW_BUF_IS_READ),
	.ccw_repeat_req(CCW_REPEAT_REQ),
	.n_rst_ccw_buf_ptrs(N_RST_CCW_BUF_PTRS)
);	  


hsi_slave HSI_SLV (
	.clk(CLK_48),
	.n_rst(N_RST),
	
	.en(USB_SDI_ON),
	
	.sd_d_tx_rdy(SD_D_TX_RDY),
	.sd_d_tx_en(SD_D_TX_EN),
	
	.sd_d(SD_D),
	.sd_d_rdy(SD_D_RDY),
	.sd_d_sending(SD_D_SENDING),
	.sd_has_next_dp(SD_HAS_NEXT_DP),
	
	
	.sd_busy(USB_SDI_FLAG_SD_BUSY),
	.usb_err_in_msg(USB_SDI_FLAG_ERR_IN_MSG),
	
	.com_en(USB_SDI_COM_EN),
	.com1(COM1),
	.com2(COM2),
	
	.dat_en(USB_SDI_DAT_EN),
	.dat1(DAT1),
	.dat2(DAT2),
	
	.q()
);

signal_trimmer SIGNAL_TRIMMER (
	.clk(CLK_48),
	.s(USB_SDI_FLAG_SERVICE_REQ & ~SD_D_TX_EN),
	.trim_s(USB_SDI_FLAG_SERVICE_REQ_TRIMMED)
);


wire [7:0] SD_D;
sd_d_gen SD_D_GEN (
	.clk(CLK_48),
	.n_rst(N_RST),
	.usb_service_req(USB_SDI_FLAG_SERVICE_REQ_TRIMMED),
	.sd_d_tx_rdy(SD_D_TX_RDY),
	.sd_d_tx_en(SD_D_TX_EN),
	.sd_d(SD_D),
	.sd_d_rdy(SD_D_RDY),
	.sd_d_sending(SD_D_SENDING),
	.sd_has_next_dp(SD_HAS_NEXT_DP)
);



	  
	  
usb_coder_connector USB_CD_CONNECTOR (
	.clk(FCLK_OUT),
	.n_rst(N_RST),
	
	.st_bytes(ST_BYTES),
	
	.sdi_bytes(SDI_BYTES),

	.csi_bytes(CSI_BYTES),
	
	.crc(), 
	
	.byte_4_tx(),
	.byte_4_tx_rdy(),

	.start_commutation(l00_MS_IS_LEFT),
	
	.byte_sent()	  
); 
	  

	 
endmodule 
