module hsi_monitor (
	input clk,
	input n_rst, 
	
	input [7:0] hsi_m_d,
	input hsi_m_d_rdy,
	input hsi_m_frame_end,
	input hsi_m_err,
	input hsi_m_ch,
	
	input [7:0] hsi_s_d,
	input hsi_s_d_rdy,
	input hsi_s_frame_end,
	input hsi_s_err,
	
	input  [7:0] st_d,
	input  st_last_byte,
	input  st_asserted,
	output st_rdreq,
	
	input  st_tx_rdy,
	output reg st_tx_ack,
	
	output reg last_frame_src,
	
	output [10:0] usedw,
	
	output reg rd_rdy,
	input rd_rdy_ack,
	
	input rdreq,
	output [7:0] q
);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		st_tx_ack = 0;
	else 
		st_tx_ack = rst_wr_en & st_tx_rdy;
end


always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		rd_rdy = 0;
	else if(rd_rdy_ack)
		rd_rdy = 0;
	else if(rst_wr_en & st_last_byte)
		rd_rdy = 1;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		last_frame_src = 0;
	else if(mstr_send)
		last_frame_src = 0;
	else if(slv_send)
		last_frame_src = 1;
end	

wire ANY_D_RDY = hsi_m_d_rdy | hsi_s_d_rdy;
wire ANY_FRAME_END = hsi_m_frame_end | hsi_s_frame_end;
wire ANY_ERR = hsi_m_err | hsi_s_err;

wire M_FRAME_END_TT_60M;
trg_trm M_FRAME_END_TRG_TRM_60M(
	.clk(clk),
	.n_rst(n_rst),
	.s(hsi_m_frame_end),
	.s_tt(M_FRAME_END_TT_60M)
);

wire S_FRAME_END_TT_60M;
trg_trm S_FRAME_END_TRG_TRM_60M(
	.clk(clk),
	.n_rst(n_rst),
	.s(hsi_s_frame_end),
	.s_tt(S_FRAME_END_TT_60M)
);


wire M_D_RDY_TT_60M;
trg_trm M_D_RDY_TRG_TRM_60M(
	.clk(clk),
	.n_rst(n_rst),
	.s(hsi_m_d_rdy),
	.s_tt(M_D_RDY_TT_60M)
);

wire S_D_RDY_TT_60M;
trg_trm S_D_RDY_TRG_TRM_60M(
	.clk(clk),
	.n_rst(n_rst),
	.s(hsi_s_d_rdy),
	.s_tt(S_D_RDY_TT_60M)
);

reg slv_send;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		slv_send = 0;
	else if(S_D_RDY_TT_60M)
		slv_send = 1;
	else if(S_FRAME_END_TT_60M)
		slv_send = 0;
end


reg mstr_send;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		mstr_send = 0;
	else if(M_D_RDY_TT_60M)
		mstr_send = 1;
	else if(M_FRAME_END_TT_60M)
		mstr_send = 0;
end

wire ANY_SEND = mstr_send | slv_send;

wire[7:0] hsi_d = slv_send ? hsi_s_d : hsi_m_d;

wire ANY_D_RDY_TT_60M = M_D_RDY_TT_60M | S_D_RDY_TT_60M;

 
reg any_d_rdy_tt_sync;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		any_d_rdy_tt_sync = 0;
	else 
		any_d_rdy_tt_sync = ANY_D_RDY_TT_60M;
end


wire ANY_FRAME_END_TT_60M = M_FRAME_END_TT_60M | S_FRAME_END_TT_60M; 
reg any_frame_end_tt_sync;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		any_frame_end_tt_sync = 0;
	else 
		any_frame_end_tt_sync = ANY_FRAME_END_TT_60M;
end



wire [7:0] ERR_AND_CH;
assign ERR_AND_CH[0] = ANY_ERR;
assign ERR_AND_CH[1] = hsi_m_ch;
assign ERR_AND_CH[7:2] = 0;

wire[7:0] ANY_SEND_MASK = ANY_SEND ? 8'hFF : 0,
			 ANY_FRAME_END_TT_60M_MASK = any_frame_end_tt_sync ? 8'hFF : 0,
			 ST_MASK = st_asserted ? 8'hFF : 0;

wire[7:0] d_to_buf = (ANY_SEND_MASK & hsi_d) | (ANY_FRAME_END_TT_60M_MASK & ERR_AND_CH) | (ST_MASK & st_d);		// 8'h01 & ~	 
			 

reg rst_wr_en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		rst_wr_en = 0;
	else if(st_last_byte)
		rst_wr_en = 0;
	else if(st_rdreq)
		rst_wr_en = 1;
end

wire ST_WRREQ = rst_wr_en & st_asserted; 

fifo_2KB MONITOR_BUF_2KB(
	.data(d_to_buf),
	.clock(clk),
	.rdreq(rdreq),
	.wrreq(any_d_rdy_tt_sync | any_frame_end_tt_sync | ST_WRREQ),
	.q(q),
	.empty(MBUF_EMPTY),
	.usedw(usedw)
);

assign st_rdreq = any_frame_end_tt_sync;

endmodule 




module trg_trm (
	input clk,
	input n_rst,
	input s,
	output s_tt
);

reg s_trg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		s_trg = 0;
	else 
		s_trg = s;
end

signal_trimmer S_TRM (
	.clk(clk),
	.s(s_trg),
	.trim_s(s_tt)
);

endmodule 





