module umio_base (

/*********************** CLK **********************/
		
		input CLK,

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
assign FU_D[7:0] = 8'hzz;
assign FODD		  = 1;
assign FOE		  = 1;
assign FSIWU	  = 1;
assign FWR		  = 1;
assign FRD		  = 1;

/************ I2C ************/

assign FSDA = 0;
assign FSCL = 0;

/*****************************/

assign FH3_D1_D 	= 0;
assign FH3_D1_nRE = 1;
assign FH3_D1_DE 	= 0;

assign FL2_D1_D	= 0;
assign FL2_D1_nRE = 1;
assign FL2_D1_DE  = 0; 
  
assign FH1_D1_D	= 0;
assign FH1_D1_nRE	= 1;
assign FH1_D1_DE	= 0;

assign FH2_D1_D	= 0;
assign FH2_D1_nRE	= 1;
assign FH2_D1_DE	= 0;

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
		
assign FH1_D2_D	= 0;
assign FH1_D2_nRE	= 1;
assign FH1_D2_DE	= 0;

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


/********************   WIRES  ********************/

wire CLK_24 = CLK;
wire CLK_8;
wire STP_CLK_24x8_192;
wire STP_CLK_8x8_64;
wire N_RST;
wire CLK_24_EN;
wire [7:0] PG_Q_CD_D;
wire PG_PL_RDY_CD_WR_EN;
wire CD_BUSY;
wire CD_Q;

/********************  MODULES ********************/

pll PLL(
	.inclk0(CLK_24),
	.c0(STP_CLK_24x8_192),
	.c1(CLK_8),
	.c2(STP_CLK_8x8_64)
);

clk_enable_controller CLK_EN_CTRL (
	.clk(CLK_24),
	.n_rst(N_RST),
	.clk_en(CLK_24_EN)
);

reset_controller RST_CTRL (
	.clk(CLK_24),
	.n_rst(N_RST)
);

payload_generator PL_GEN (
	.clk(CLK_24),
	.n_rst(N_RST),
	.clk_en(CLK_24_EN),
	.cd_busy(CD_BUSY),
	.q(PG_Q_CD_D),
	.pl_rdy(PG_PL_RDY_CD_WR_EN)
);

coder CD (
	.clk(CLK_24),
	.n_rst(N_RST),
	.clk_en(CLK_24_EN),
	.d(PG_Q_CD_D),
	.wr_en(PG_PL_RDY_CD_WR_EN),
	.busy(CD_BUSY),
	.q(CD_Q)
);

decoder DC (
	.clk(CLK_8),
	.n_rst(N_RST),
	.d(CD_Q),
	.q(),
	.q_rdy(),
	.err()
);

endmodule
