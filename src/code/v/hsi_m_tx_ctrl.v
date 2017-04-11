module hsi_m_tx_ctrl (
	input clk,
	input clk_en,
	input n_rst,
	
	input sdreq_en,
	input sr_tx_rdy,
	output sr_tx_ack,
	
	input tm_tx_en,
	input tm_tx_rdy,
	output tm_tx_ack,
	input pre_tm,
	
	input btc_en,
	input [39:0] btc,
	input [7:0] ccw_d,
	input ccw_tx_rdy,
	output ccw_tx_en,
	output ccw_d_sending,
	input ccw_d_rdy,
	
	input com_src,
	output com1,
	output com2
);

`include "src/code/vh/hsi_config.vh"

assign tm_tx_ack = SENDING_TM;
assign sr_tx_ack = SENDING_SR;

assign com1 = CD_Q & com_src;
assign com2 = CD_Q & (~com_src);

assign ccw_d_sending = CD_BUSY & ccw_tx_en & ccw_tx_rdy;

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
	  
	  
wire TM_TX_RDY_MASKED  = tm_tx_en & tm_tx_rdy,
	  BTC_TX_RDY_MASKED = btc_en & BTC_TX_RDY,
	  SR_TX_RDY_MASKED  = sdreq_en & sr_tx_rdy,
	  CCW_RX_RDY        = ~pre_tm & ccw_tx_rdy & ~DELAY_100_US; // ccw_tx_rdy чтобы УКС передавалась во время pre_tm
	  

wire SENDING_TM  = (tx_state == TX_STATE_SENDING_TM),
	  SENDING_BTC = (tx_state == TX_STATE_SENDING_BTC),
	  SENDING_SR  = (tx_state == TX_STATE_SENDING_SR),
	  SENDING_DPR = (tx_state == TX_STATE_SENDING_DPR),
	  SENDING_CCW = (tx_state == TX_STATE_SENDING_CCW),
	  SENDING_CRC = (tx_state == TX_STATE_SENDING_CRC),
	  DELAY_100_US = (tx_state == TX_STATE_DELAY_100_US); 
	  
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
	.tx_state(TX_STATE_TM_SR_DPR),
	.cd_busy(CD_BUSY),
	.q(D_TM_SR_DPR),
	.q_rdy(D_RDY_TM_SR_DPR),
	.msg_end(MSG_END_TM_SR_DPR)
);

wire[7:0] D_TM_SR_DPR;

wire[2:0] TX_STATE_TM_SR_DPR;
assign TX_STATE_TM_SR_DPR[0] = SENDING_TM;
assign TX_STATE_TM_SR_DPR[1] = SENDING_SR;
assign TX_STATE_TM_SR_DPR[2] = SENDING_DPR;


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

tm_cntr TM_CNTR (
	.clk(clk),
	.n_rst(n_rst),
	.tm_msg_end(MSG_END_TM),
	.sending_btc(SENDING_BTC),
	.btc_tx_rdy(BTC_TX_RDY)
);

tim_100_us TIM_100_US (
	.clk(clk),
	.n_rst(n_rst & DELAY_100_US),
	.l00_us_is_left(l00_US_IS_LEFT)
);

btc_ctrl BTC_CTRL (
	.clk(clk),
	.n_rst(n_rst),
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
	.ccw_d_rdy(ccw_d_rdy),
	.q(D_CCW),
	.q_rdy(D_RDY_CCW),
	.msg_end(MSG_END_CCW)
);

m_connector CONNECTOR (
	.tx_state(TX_STATE_CONNECTOR),
	.d_rdy_src(D_RDY_SRC),
	.d_rdy_dst(TX_D_RDY),
	.d_src(D_SRC),
	.d_dst(TX_D)
);

wire[5:0] TX_STATE_CONNECTOR;
assign TX_STATE_CONNECTOR[0] = SENDING_TM;
assign TX_STATE_CONNECTOR[1] = SENDING_BTC;
assign TX_STATE_CONNECTOR[2] = SENDING_SR;
assign TX_STATE_CONNECTOR[3] = SENDING_DPR;
assign TX_STATE_CONNECTOR[4] = SENDING_CCW;
assign TX_STATE_CONNECTOR[5] = SENDING_CRC;

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

reg[2:0] tx_state;
parameter TX_STATE_CTRL = 0,
			 TX_STATE_SENDING_TM  = 1,
			 TX_STATE_SENDING_BTC = 2,
			 TX_STATE_SENDING_SR  = 3, 		 
			 TX_STATE_SENDING_DPR = 4, 
			 TX_STATE_SENDING_CCW = 5, 				 
			 TX_STATE_SENDING_CRC = 6,
			 TX_STATE_DELAY_100_US = 7;

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			tx_state = TX_STATE_CTRL;
		end
	else
		begin
			case(tx_state)
			TX_STATE_CTRL:
				begin
					if(TM_TX_RDY_MASKED)
						tx_state = TX_STATE_SENDING_TM;
					else if(BTC_TX_RDY_MASKED)
						tx_state = TX_STATE_SENDING_BTC;
					else if(SR_TX_RDY_MASKED)
						tx_state = TX_STATE_SENDING_SR;
					else if(CCW_RX_RDY)
						tx_state = TX_STATE_SENDING_CCW;
				end
			TX_STATE_SENDING_TM:
				begin
					if(MSG_END_TM)
						tx_state = TX_STATE_SENDING_CRC;
					else
						tx_state = TX_STATE_SENDING_TM;
				end
			TX_STATE_SENDING_BTC:
				begin
					if(MSG_END_BTC)
						tx_state = TX_STATE_SENDING_CRC;
					else
						tx_state = TX_STATE_SENDING_BTC;
				end
			TX_STATE_SENDING_SR:
				begin
					if(MSG_END_SR)
						tx_state = TX_STATE_SENDING_CRC;
					else
						tx_state = TX_STATE_SENDING_SR;
				end
			TX_STATE_SENDING_DPR:
				begin
					if(MSG_END_DPR)
						tx_state = TX_STATE_SENDING_CRC;
					else
						tx_state = TX_STATE_SENDING_DPR;
				end		
			TX_STATE_SENDING_CCW:
				begin
					if(MSG_END_CCW)
						tx_state = TX_STATE_SENDING_CRC;
					else
						tx_state = TX_STATE_SENDING_CCW;
				end
			TX_STATE_SENDING_CRC:	
				begin
					if(MSG_END_CRC)
						tx_state = TX_STATE_DELAY_100_US;
					else
						tx_state = TX_STATE_SENDING_CRC;
				end
			TX_STATE_DELAY_100_US:	
				begin
					if(l00_US_IS_LEFT)
						tx_state = TX_STATE_CTRL;
					else
						tx_state = TX_STATE_DELAY_100_US;
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


module tim_100_us(
	input clk,
	input n_rst,
	output l00_us_is_left
);
assign l00_us_is_left = (ticks == (((`CLK_FREQ) / 1000000) * 100) - 1);
reg[12:0] ticks;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ticks = 0;
	else 
		ticks = ticks + 1;
end
endmodule


module tm_cntr (
	input clk,
	input n_rst,
	input tm_msg_end,
	output reg btc_tx_rdy,
	input sending_btc
);

wire hz_mark = (`TM_FREQ == `Hz_1) ? tm_msg_end : l0th_tm_msg_end;

wire l0th_tm_msg_end = (tm_me_cntr == 10);
reg[3:0] tm_me_cntr;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tm_me_cntr = 0;
	else if(sending_btc)
		tm_me_cntr = 0;
	else if(tm_msg_end)
		tm_me_cntr = tm_me_cntr + 1;
end 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		btc_tx_rdy = 0;
	else if(hz_mark)
		btc_tx_rdy = 1;
	else if(sending_btc)
		btc_tx_rdy = 0;
end
endmodule 