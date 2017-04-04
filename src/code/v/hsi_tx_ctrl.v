module hsi_tx_ctrl (
	input clk,
	input clk_en,
	input n_rst,
	input sdreq_en,
	input tm_en,
	input tm,
	input pre_tm,
	input btc_en,
	input [39:0] btc,
	input [7:0] ccw_d,
	input ccw_tx_rdy,
	output ccw_tx_en,
	output cd_busy,
	input byte_hold,
	
	input com_src,
	output com1,
	output com2
);

`include "src/code/vh/hsi_master_config.vh"


assign com1 = CD_Q & com_src;
assign com2 = CD_Q & (~com_src);

assign cd_busy = CD_BUSY & ccw_tx_en & ccw_tx_rdy;

wire TX_D_RDY,
	  TX_D_RDY_TRIMMED,
	  TX_MSG_END;
	  
wire[7:0] TX_D;
wire[15:0] CRC16;

wire[7:0] D_TM,
			 D_BTC,
			 D_SR,  
			 D_DPR, 
			 D_CCW, 
          D_CRC;
		
wire D_RDY_TM,
	  D_RDY_BTC,
     D_RDY_SR,
	  D_RDY_DPR,
	  D_RDY_CCW,
	  D_RDY_CRC;

wire MSG_END_TM,
	  MSG_END_BTC,
     MSG_END_SR,
	  MSG_END_DPR,
	  MSG_END_CCW;
	  
	  
wire TM_TX_RDY_MASKED  = tm_en & tm,
	  BTC_TX_RDY_MASKED = btc_en & BTC_TX_RDY,
	  CCW_RX_RDY        = ~pre_tm & ccw_tx_rdy, // ccw_tx_rdy чтобы УКС передавалась во время pre_tm
	  TIME4SR_MASKED    = TIME4SR & sdreq_en;
	  
wire BTC_START_DELAY_MASKED = BTC_START_DELAY & btc_en; 	  

wire SENDING_TM  = (common_state == COM_STATE_SENDING_TM),
	  SENDING_BTC = (common_state == COM_STATE_SENDING_BTC),
	  SENDING_SR  = (common_state == COM_STATE_SENDING_SR),
	  SENDING_DPR = (common_state == COM_STATE_SENDING_DPR),
	  SENDING_CCW = (common_state == COM_STATE_SENDING_CCW),
	  SENDING_CRC = (common_state == COM_STATE_SENDING_CRC); 
	  
coder CD (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(clk_en),
	.d(TX_D),
	.d_rdy(TX_D_RDY),
	.busy(CD_BUSY),
	.q(CD_Q)
);

tm_sr_dpr_ctrl TM_SR_DPR_CTRL (
	.clk(clk),
	.common_state(COMMON_STATE_TM_SR_DPR),
	.cd_busy(CD_BUSY),
	.q(D_TM_SR_DPR),
	.q_rdy(D_RDY_TM_SR_DPR),
	.msg_end(MSG_END_TM_SR_DPR)
);

wire[7:0] D_TM_SR_DPR;

wire[2:0] COMMON_STATE_TM_SR_DPR;
assign COMMON_STATE_TM_SR_DPR[0] = SENDING_TM;
assign COMMON_STATE_TM_SR_DPR[1] = SENDING_SR;
assign COMMON_STATE_TM_SR_DPR[2] = SENDING_DPR;


assign MSG_END_TM  = SENDING_TM  & MSG_END_TM_SR_DPR;
assign MSG_END_SR  = SENDING_SR  & MSG_END_TM_SR_DPR;
assign MSG_END_DPR = SENDING_DPR & MSG_END_TM_SR_DPR;

signal_trimmer SIGNAL_TRIMMER (
	.clk(clk),
	.s(TX_D_RDY),
	.trim_s(TX_D_RDY_TRIMMED)
);

crc_sender CRC_SENDER  (
	.clk(clk),
	.crc_tx_en(SENDING_CRC),
	.crc(CRC16),
	.crc_rdy(MSG_END_TM|MSG_END_BTC|MSG_END_SR|MSG_END_DPR|MSG_END_CCW),
	.cd_busy(CD_BUSY),
	.q_rdy(D_RDY_CRC),
	.q(D_CRC),
	.msg_end(MSG_END_CRC)
);

crc16_citt_calc CRC16_CITT_CALC (
	.clk(clk),
	.n_rst(n_rst & ~(SENDING_CRC)),
	.d(TX_D),
	.en(TX_D_RDY_TRIMMED),
	.crc(CRC16)
);

tm_fe_cntr TM_FE_CNTR (
	.clk(clk),
	.n_rst(n_rst),
	.tm_fr_end(FRAME_END_TM),
	.btc_start_delay(BTC_START_DELAY)
);

btc_ctrl BTC_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.start_delay(BTC_START_DELAY_MASKED),
	.btc(btc),
	.btc_tx_rdy(BTC_TX_RDY),
	.btc_tx_en(SENDING_BTC),
	.cd_busy(CD_BUSY),
	.q_rdy(D_RDY_BTC),
	.q(D_BTC),
	.msg_end(MSG_END_BTC)
);


ccw_ctrl CCW_CTRL (
	.clk(clk),
	.n_rst(n_rst),
	.ccw_d(ccw_d),
	.tx_rdy(CCW_RX_RDY & SENDING_CCW),
	.tx_en(ccw_tx_en),
	.cd_busy(CD_BUSY),
	.byte_hold(byte_hold),
	.q(D_CCW),
	.q_rdy(D_RDY_CCW),
	.msg_end(MSG_END_CCW)
);

sr_timer SR_TIMER (
	.clk(clk),
	.n_rst(n_rst),
	.time4sr(TIME4SR)
);

frame_end_alert FE_ALERT(
	.clk(clk),
	.me_ctrls(MSG_END_CTRLS),
	.me_crc(MSG_END_CRC),
	.fe(FRAME_END) 
);

connector CONNECTOR (
	.common_state(COMMON_STATE_CONNECTOR),
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

wire[2:0] MSG_END_CTRLS;
assign MSG_END_CTRLS[0] = MSG_END_TM_SR_DPR;
assign MSG_END_CTRLS[1] = MSG_END_BTC;
assign MSG_END_CTRLS[2] = MSG_END_CCW;

wire[5:0] COMMON_STATE_CONNECTOR;
assign COMMON_STATE_CONNECTOR[0] = SENDING_TM;
assign COMMON_STATE_CONNECTOR[1] = SENDING_BTC;
assign COMMON_STATE_CONNECTOR[2] = SENDING_SR;
assign COMMON_STATE_CONNECTOR[3] = SENDING_DPR;
assign COMMON_STATE_CONNECTOR[4] = SENDING_CCW;
assign COMMON_STATE_CONNECTOR[5] = SENDING_CRC;

wire[3:0] D_RDY_SRC;
assign D_RDY_SRC[0] = D_RDY_TM_SR_DPR;
assign D_RDY_SRC[1] = D_RDY_BTC;
assign D_RDY_SRC[2] = D_RDY_CCW;
assign D_RDY_SRC[3] = D_RDY_CRC;

wire[31:0] D_SRC;
assign D_SRC[7:0]   = D_TM_SR_DPR;
assign D_SRC[15:8]  = D_BTC;
assign D_SRC[23:16] = D_CCW;  
assign D_SRC[31:24] = D_CRC;

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
					else if (TIME4SR_MASKED)
						common_state = COM_STATE_SENDING_SR;
					else if(CCW_RX_RDY)
						common_state = COM_STATE_SENDING_CCW;
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
			COM_STATE_SENDING_SR:
				begin
					if(MSG_END_SR)
						common_state = COM_STATE_SENDING_CRC;
					else
						common_state = COM_STATE_SENDING_SR;
				end
			COM_STATE_SENDING_DPR:
				begin
					if(MSG_END_DPR)
						common_state = COM_STATE_SENDING_CRC;
					else
						common_state = COM_STATE_SENDING_DPR;
				end		
			COM_STATE_SENDING_CCW:
				begin
					if(MSG_END_CCW)
						common_state = COM_STATE_SENDING_CRC;
					else
						common_state = COM_STATE_SENDING_CCW;
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

module tm_fe_cntr (
	input clk,
	input n_rst,
	input tm_fr_end,
	output btc_start_delay
);
reg[3:0] tm_fe_cntr;
assign btc_start_delay = (`TM_FREQ == `Hz_1) ? tm_fr_end : (tm_fe_cntr == `TM_FREQ);
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tm_fe_cntr = 0;
	else if(btc_start_delay)
		tm_fe_cntr = 0;
	else if(tm_fr_end)
		tm_fe_cntr = tm_fe_cntr + 1;
end 
endmodule 