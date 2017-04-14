module sd_d_gen (
	input  clk,
	input  n_rst,
	input  sd_d_accepted,
	output sd_d_tx_rdy,
	input  sd_d_tx_en,
	output [7:0] sd_d,
	output sd_d_rdy,
	input  sd_d_sending,
	output sd_has_next_frame
);

`include "src/code/vh/hsi_config.vh"

parameter FRAME_COUNT = 2,
			 INI_VAL     = 16'h0000,
			 LAST_VAL    = INI_VAL + `S_DP_LEN_IN_WORDS;

assign sd_d_rdy = ~sd_d_sending & sd_d_tx_en;

assign sd_has_next_frame = (frame_cntr > 0);

reg[7:0] frame_cntr;
wire N_RST_BY_SD_D_ACCEPTED = n_rst & ~sd_d_accepted;
always@(posedge sd_d_tx_en or negedge N_RST_BY_SD_D_ACCEPTED)
begin
	if(N_RST_BY_SD_D_ACCEPTED == 0)
		frame_cntr = (FRAME_COUNT - 1);
	else if(sd_has_next_frame)
		frame_cntr = frame_cntr - 1;
end

reg[15:0] sd_d_16; 

reg sd_has_data;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		sd_has_data = 0;
	else if(sd_d_accepted)
		sd_has_data = 1;
	else if(sd_d_16 == LAST_VAL)
		sd_has_data = 0;
end

assign sd_d_tx_rdy = sd_has_data | sd_d_sending;

wire N_RST_EVERY_2ND_SD_D_SENDING = n_rst & sd_d_tx_en;
reg every_2nd_sd_d_sending;
always@(posedge sd_d_sending or negedge N_RST_EVERY_2ND_SD_D_SENDING)
begin
	if(N_RST_EVERY_2ND_SD_D_SENDING == 0)
		every_2nd_sd_d_sending = 0;
	else
		every_2nd_sd_d_sending = ~every_2nd_sd_d_sending;
end

reg sd_d_16_incr_en;
always@(posedge sd_d_sending or negedge sd_d_tx_en)
begin
	if(sd_d_tx_en == 0)
		sd_d_16_incr_en = 0;
	else if(every_2nd_sd_d_sending)
		sd_d_16_incr_en = 1;
end


assign sd_d = every_2nd_sd_d_sending ? sd_d_16[15:8] : sd_d_16[7:0];

always@(posedge every_2nd_sd_d_sending or negedge N_RST_BY_SD_D_ACCEPTED)
begin
	if(N_RST_BY_SD_D_ACCEPTED == 0)
		sd_d_16 = INI_VAL;
	else if(sd_d_16_incr_en)
		sd_d_16 = sd_d_16 + 1;
end	

endmodule 