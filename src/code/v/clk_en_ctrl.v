module clk_en_ctrl (
	input  clk,
	input  n_rst,
	output tx_clk_en,
	output rx_clk_en
);

`include "src/code/vh/hsi_master_config.vh"		

reg[8:0] tx_cntr;
reg[5:0] rx_cntr;

assign tx_clk_en = (tx_cntr == `TX_DIV_FACTOR);
assign rx_clk_en = (rx_cntr == `RX_DIV_FACTOR);

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