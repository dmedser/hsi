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
	.c2(STP_CLK_8x8_64)
);

reset_controller RST_CTRL (
	.clk(CLK_48),
	.n_rst(N_RST)
);

hsi_master HSI_MSTR(
	.clk(CLK_48),
	.n_rst(N_RST),
	
	.sdreq_en(1),
	.sr_tx_rdy(SR_TX_RDY),
	.sr_tx_ack(SR_TX_ACK),
	.sr_repeat_req(SR_REPEAT_REQ),
	
	.tm_tx_en(1),
	.tm_tx_rdy(TM_TX_RDY),
	.tm_tx_ack(TM_TX_ACK),
	.pre_tm(PRE_TM),
	
	.btc_en(1),
	.btc(40'hABCDEF1122),
	
	.ccw_accepted(CCW_ACCEPTED),
	.ccw_tx_rdy(CCW_TX_RDY),
	.ccw_tx_en(CCW_TX_EN),
	.ccw_d(CCW_D),
	.ccw_d_rdy(CCW_D_RDY),
	.ccw_d_sending(CCW_D_SENDING),
	.ccw_repeat_req(CCW_REPEAT_REQ),
	
	
	.base_com(0),
	.dat_src(1),
	
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
	.pre_tm(PRE_TM)
);

ftdi_ctrl FTDI_CTRL (
	.clk(FCLK_OUT),
	.n_rst(N_RST),
	.oe(FOE),
	.rxf(FRXF),
	.rd(FRD),
	.ccw_accepted(CCW_ACCEPTED),
	.sd_d_accepted(SD_D_ACCEPTED),
	.sd_busy(SD_BUSY),
	.txe(FTXE),
	.wr(FWR),
	.dq(FU_D),
	.d(),
	.q()
);

wire [7:0] CCW_D;
ccw_gen CCW_GEN (
	.clk(CLK_48),
	.n_rst(N_RST),
	.ccw_accepted(CCW_ACCEPTED),
	.ccw_repeat_req(CCW_REPEAT_REQ),
	.ccw_tx_rdy(CCW_TX_RDY),
	.ccw_tx_en(CCW_TX_EN),
	.ccw_d(CCW_D),
	.ccw_d_rdy(CCW_D_RDY),
	.ccw_d_sending(CCW_D_SENDING)
);


hsi_slave HSI_SLV (
	.clk(CLK_48),
	.n_rst(N_RST),
	
	.sd_busy(SD_BUSY),

	.sd_d_tx_rdy(SD_D_TX_RDY),
	.sd_d_tx_en(SD_D_TX_EN),
	
	.sd_d(SD_D),
	.sd_d_rdy(SD_D_RDY),
	.sd_d_sending(SD_D_SENDING),
	.sd_has_next_dp(SD_HAS_NEXT_DP),
	

	
	.com1(COM1),
	.com2(COM2),
	
	.dat1(DAT1),
	.dat2(DAT2),
	
	.q()
);

wire [7:0] SD_D;
sd_d_gen SD_D_GEN (
	.clk(CLK_48),
	.n_rst(N_RST),
	.sd_d_accepted(SD_D_ACCEPTED),
	.sd_d_tx_rdy(SD_D_TX_RDY),
	.sd_d_tx_en(SD_D_TX_EN),
	.sd_d(SD_D),
	.sd_d_rdy(SD_D_RDY),
	.sd_d_sending(SD_D_SENDING),
	.sd_has_next_dp(SD_HAS_NEXT_DP)
);

endmodule
