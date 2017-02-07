module clk_enable_controller (
	input 	clk,
	input 	n_rst,
	output 	clk_en
);

assign clk_en = (counter == CLK_DIV_FACTOR);

reg[4:0] counter;
parameter CLK_DIV_FACTOR = 23 - 1;

always@(posedge clk)
begin
	if(n_rst == 0)
		begin
			counter = 0;
		end
	else
		begin
			if(counter == CLK_DIV_FACTOR)
				begin
					counter = 0;
				end
			else	
				begin
					counter = counter + 1;
				end
		end
end

endmodule