module hsi_master (
	input clk,
	input n_rst,
	input sdreq_en,
	input tm_en,
	input tm,
	input pre_tm,
	input btc_en,
	input [39:0] btc,
	input [7:0] ccw,
	input ccw_tx_rdy,
	output ccw_rx_rdy,
	
	input com_src,
	input dat_src,
	
	output reg [7:0] q,

	output com1,
	output com2,
	input dat1,
	input dat2
);

`include "src/code/vh/hsi_master_config.vh"

//wire DC_D = dat_src ? dat1 : dat2;	

//assign com1 = CD_Q & com_src;
//assign com2 = CD_Q & (~com_src);

wire TX_D_RDY,
	  TX_D_RDY_TRIMMED,
	  TX_MSG_END;

wire[7:0] TX_D;
wire[15:0] CRC16;

wire[7:0] D_TM_CTRL,
			 D_BTC_CTRL,
			 D_SR_CTRL,  
			 D_DPR_CTRL, 
			 D_CCW_CTRL, 
          D_CRC_SNDR;
		
wire D_RDY_TM_CTRL,
	  D_RDY_BTC_CTRL,
     D_RDY_SR_CTRL,
	  D_RDY_DPR_CTRL,
	  D_RDY_CCW_CTRL,
	  D_RDY_CRC_SNDR;

wire MSG_END_TM,
	  MSG_END_BTC,
     MSG_END_SR,
	  MSG_END_DPR,
	  MSG_END_CCW;

	  
wire TM_TX_RDY_MASKED = tm_en & tm;
wire BTC_TX_RDY_MASKED = btc_en & BTC_TX_RDY;
	  
clk_en_ctrl CLK_EN_CTRL(
	.clk(clk),
	.n_rst(n_rst),
	.tx_clk_en(CD_CLK_EN),
	.rx_clk_en(DC_CLK_EN)
);

coder CD (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(CD_CLK_EN),
	.d(TX_D),
	.d_rdy(TX_D_RDY),
	.busy(CD_BUSY),
	.q(CD_Q)
);

decoder DC (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(DC_CLK_EN),
	.d(CD_Q),
	.q(),
	.q_rdy(),
	.err(),
	.msg_end()
);

tm_ctrl TM_CTRL (
	.clk(clk),
	.tm_tx_en(common_state == COM_STATE_SENDING_TM),
	.cd_busy(CD_BUSY),
	.q(D_TM_CTRL),
	.q_rdy(D_RDY_TM_CTRL),
	.msg_end(MSG_END_TM)
);

signal_trimmer SIGNAL_TRIMMER (
	.clk(clk),
	.s(TX_D_RDY),
	.trim_s(TX_D_RDY_TRIMMED)
);

crc_sender CRC_SENDER  (
	.clk(clk),
	.crc_tx_en(common_state == COM_STATE_SENDING_CRC),
	.crc(CRC16),
	.crc_rdy(MSG_END_TM|MSG_END_BTC|MSG_END_SR|MSG_END_DPR|MSG_END_CCW),
	.cd_busy(CD_BUSY),
	.q_rdy(D_RDY_CRC_SNDR),
	.q(D_CRC_SNDR),
	.msg_end(MSG_END_CRC)
);

crc16_citt_calc CRC16_CITT_CALC (
	.clk(clk),
	.n_rst(n_rst & ~(common_state == COM_STATE_SENDING_CRC)),
	.d(TX_D),
	.en(TX_D_RDY_TRIMMED),
	.crc(CRC16)
);

tm_cntr TM_CNTR (
	.clk(clk),
	.n_rst(n_rst),
	.tm_fr_end(FRAME_END_TM),
	.btc_start_delay(BTC_START_DELAY)
);

wire BTC_START_DELAY_MASKED = BTC_START_DELAY & btc_en; 

btc_ctrl BTC_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.start_delay(BTC_START_DELAY_MASKED),
	.btc(btc),
	.btc_tx_rdy(BTC_TX_RDY),
	.btc_tx_en(common_state == COM_STATE_SENDING_BTC),
	.cd_busy(CD_BUSY),
	.q_rdy(D_RDY_BTC_CTRL),
	.q(D_BTC_CTRL),
	.msg_end(MSG_END_BTC)
);

frame_end_alert FE_ALERT(
	.clk(clk),
	.me_ctrls(MSG_END_CTRLS),
	.me_crc(MSG_END_CRC),
	.fe(FRAME_END) 
);

connector CONNECTOR (
	.common_state(COMMON_STATE),
	.d_rdy_src(D_RDY_SRC),
	.d_rdy_dst(TX_D_RDY),
	.d_src(D_SRC),
	.d_dst(TX_D)
);

wire[4:0] FRAME_END;
wire FRAME_END_TM  = FRAME_END[0],
	  FRAME_END_BTC = FRAME_END[1],
	  FRAME_END_SR  = FRAME_END[2],
	  FRAME_END_DPR = FRAME_END[3],
	  FRAME_END_CCW = FRAME_END[4]; 

wire[4:0] MSG_END_CTRLS;
assign MSG_END_CTRLS[0] = MSG_END_TM;
assign MSG_END_CTRLS[1] = MSG_END_BTC;
assign MSG_END_CTRLS[2] = MSG_END_SR;
assign MSG_END_CTRLS[3] = MSG_END_DPR;
assign MSG_END_CTRLS[4] = MSG_END_CCW;

wire[5:0] COMMON_STATE;
assign COMMON_STATE[0] = (common_state == COM_STATE_SENDING_TM);
assign COMMON_STATE[1] = (common_state == COM_STATE_SENDING_BTC);
assign COMMON_STATE[2] = (common_state == COM_STATE_SENDING_SR);
assign COMMON_STATE[3] = (common_state == COM_STATE_SENDING_DPR);
assign COMMON_STATE[4] = (common_state == COM_STATE_SENDING_CCW);
assign COMMON_STATE[5] = (common_state == COM_STATE_SENDING_CRC);

wire[5:0] D_RDY_SRC;
assign D_RDY_SRC[0] = D_RDY_TM_CTRL;
assign D_RDY_SRC[1] = D_RDY_BTC_CTRL;
assign D_RDY_SRC[2] = D_RDY_SR_CTRL;
assign D_RDY_SRC[3] = D_RDY_DPR_CTRL;
assign D_RDY_SRC[4] = D_RDY_CCW_CTRL;
assign D_RDY_SRC[5] = D_RDY_CRC_SNDR;

wire[47:0] D_SRC;
assign D_SRC[7:0]   = D_TM_CTRL;
assign D_SRC[15:8]  = D_BTC_CTRL;
assign D_SRC[23:16] = D_SR_CTRL;  
assign D_SRC[31:24] = D_DPR_CTRL; 
assign D_SRC[39:32] = D_CCW_CTRL; 
assign D_SRC[47:40] = D_CRC_SNDR;  

reg[2:0] common_state;
parameter COM_STATE_CTRL = 0,
			 COM_STATE_SENDING_TM  = 1,
			 COM_STATE_SENDING_BTC = 2,
			 COM_STATE_SENDING_SR  = 3, 		 
			 COM_STATE_SENDING_DPR = 4, 
			 COM_STATE_SENDING_CCW = 5, 				 
			 COM_STATE_SENDING_CRC = 6;				 

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			common_state = COM_STATE_CTRL;
		end
	else
		begin
			case(common_state)
			COM_STATE_CTRL:
				begin
					if(TM_TX_RDY_MASKED)
						common_state = COM_STATE_SENDING_TM;
					else if(BTC_TX_RDY_MASKED)
						common_state = COM_STATE_SENDING_BTC;
				end
			COM_STATE_SENDING_TM:
				begin
					if(MSG_END_TM)
						common_state = COM_STATE_SENDING_CRC;
					else
						common_state = COM_STATE_SENDING_TM;
				end
			COM_STATE_SENDING_BTC:
				begin
					if(MSG_END_BTC)
						common_state = COM_STATE_SENDING_CRC;
					else
						common_state = COM_STATE_SENDING_BTC;
				end
			COM_STATE_SENDING_CRC:	
				begin
					if(MSG_END_CRC)
						common_state = COM_STATE_CTRL;
					else
						common_state = COM_STATE_SENDING_CRC;
				end
			default:
				begin
				
				end
			endcase
		end
end
endmodule


module signal_trimmer (
	input clk,
	input s,
	output trim_s
);
reg sync_s;
always@(posedge clk) 
begin
	if(s == 1)
		sync_s = 1;
	else
		sync_s = 0;
end
assign trim_s = s & ~sync_s;
endmodule

module tm_cntr (
	input clk,
	input n_rst,
	input tm_fr_end,
	output btc_start_delay
);
reg[3:0] tm_cntr;
assign btc_start_delay = (`TM_FREQ == `HZ_1) ? tm_fr_end : (tm_cntr == `TM_FREQ);
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tm_cntr = 0;
	else if(btc_start_delay)
		tm_cntr = 0;
	else if(tm_fr_end)
		tm_cntr = tm_cntr + 1;
end
endmodule 



