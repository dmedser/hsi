module payload_generator (
	input clk,
	input n_rst,
	input clk_en,
	output reg pl_rdy,
	output reg [7:0] q,
	input cd_busy
);

parameter OFF = 0,
			 ON  = 1;	
			 
/********** GENERATION PERIOD TIMER **********/

reg [4:0] ticks;
parameter GEN_PERIOD = 31;  // 10			 

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			ticks = 0;
		end
	else if(clk_en == ON)
		begin
			if(ticks < GEN_PERIOD)
				begin
					ticks = ticks + 1;
				end
			else 
				begin
					ticks = 0;
				end
		end
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			pl_rdy = OFF;
			q = 8'h55;
		end
	else if(clk_en == ON)
		begin								
		if(cd_busy == OFF)		// 
				begin
					if(ticks == 0)
						begin
							pl_rdy = ON;
						end
					else if(ticks == GEN_PERIOD)
						begin
							q = q + 1;
						end
				end
			else							//
				begin
					pl_rdy = OFF;
				end
		end
end


endmodule 