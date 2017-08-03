module m_clk_en_ctrl (
	input  clk,
	input  n_rst,
	output tx_clk_en,
	output rx_clk_en
);

`include "src/code/vh/hsi_config.vh"		

reg[8:0] tx_cntr;
reg[5:0] rx_cntr;

assign tx_clk_en = (tx_cntr == `M_TX_DIV_FACTOR);
assign rx_clk_en = (rx_cntr == `M_RX_DIV_FACTOR);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			tx_cntr = 0;
		end
	else
		begin
			if(tx_clk_en)
				begin
					tx_cntr = 0;
				end
			else
				begin
					tx_cntr = tx_cntr + 1;
				end
		end
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			rx_cntr = 0;
		end
	else
		begin
			if(rx_clk_en)
				begin
					rx_cntr = 0;
				end
			else
				begin 
					rx_cntr = rx_cntr + 1;
				end
		end
end

endmodule


module s_clk_en_ctrl (
	input  clk,
	input  n_rst,
	output tx_clk_en,
	output rx_clk_en
);

`include "src/code/vh/hsi_config.vh"		

reg[8:0] tx_cntr;
reg[5:0] rx_cntr;

assign tx_clk_en = (tx_cntr == `S_TX_DIV_FACTOR);
assign rx_clk_en = (rx_cntr == `S_RX_DIV_FACTOR);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			tx_cntr = 0;
		end
	else
		begin
			if(tx_clk_en)
				begin
					tx_cntr = 0;
				end
			else
				begin
					tx_cntr = tx_cntr + 1;
				end
		end
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			rx_cntr = 0;
		end
	else
		begin
			if(rx_clk_en)
				begin
					rx_cntr = 0;
				end
			else
				begin 
					rx_cntr = rx_cntr + 1;
				end
		end
end

endmodule


//
//module monitor_clk_en_ctrl (
//	input  clk,
//	input  n_rst,
//	output dc_mm_clk_en,
//	output dc_sm_clk_en
//);
//
//`include "src/code/vh/hsi_config.vh"		
//
//reg[5:0] m_rx_cntr;
//reg[5:0] s_rx_cntr; /* M_1M - S_8M(48/8 = 6), M_125K - S_1M(48/48 = 1) */
//
//assign dc_sm_clk_en = (m_rx_cntr == `M_RX_DIV_FACTOR);
//assign dc_mm_clk_en = (s_rx_cntr == `S_RX_DIV_FACTOR);
//
//always@(posedge clk or negedge n_rst)
//begin
//	if(n_rst == 0)
//			m_rx_cntr = 0;
//	else
//		begin
//			if(dc_sm_clk_en)
//				m_rx_cntr = 0;
//			else
//				m_rx_cntr = m_rx_cntr + 1;
//		end
//end
//
//always@(posedge clk or negedge n_rst)
//begin
//	if(n_rst == 0)
//			s_rx_cntr = 0;
//	else
//		begin
//			if(dc_mm_clk_en)
//				s_rx_cntr = 0;
//			else
//				s_rx_cntr = s_rx_cntr + 1;
//		end
//end
//
//endmodule 
