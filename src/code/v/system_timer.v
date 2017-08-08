module system_timer (
	input clk,
	input n_rst,
	
	input preset,
	
	inout [15:0] day,
	inout [26:0] ms_of_day,
	inout [9:0]  us_of_ms
);

assign day       = preset ? 16'hZZZZ : DAY_REG; 
assign ms_of_day = preset ? 27'bZZZZZZZZZZZZZZZZZZZZZZZZZZZ : MS_OF_DAY_REG;
assign us_of_ms  = preset ? 10'bZZZZZZZZZZ : US_OF_MS_REG;

us_tim US_TIM (
	.clk(clk),
	.n_rst(n_rst),
	.us_is_over(US_IS_OVER)
);

us_of_ms_tim US_OF_MS_TIM (
	.clk(clk),
	.n_rst(n_rst),
	.preset(preset),
	.us_of_ms_preset(us_of_ms),
	.us_of_ms_reg(US_OF_MS_REG),
	.us_is_over(US_IS_OVER),
	.ms_is_over(MS_IS_OVER)
);

ms_of_day_tim MS_OF_DAY_TIM (
	.clk(clk),
	.n_rst(n_rst),
	.preset(preset),
	.ms_of_day_preset(ms_of_day),
	.ms_of_day_reg(MS_OF_DAY_REG),
	.ms_is_over(MS_IS_OVER),
	.day_is_over(DAY_IS_OVER)
);

day_tim DAY_TIM (
	.clk(clk),
	.n_rst(n_rst),
	.preset(preset),
	.day_preset(day),
	.day_reg(DAY_REG),
	.day_is_over(DAY_IS_OVER)
);


wire US_IS_OVER,
	  MS_IS_OVER,
	  DAY_IS_OVER;

wire[15:0] DAY_REG;
wire[26:0] MS_OF_DAY_REG;
wire[9:0]  US_OF_MS_REG;
endmodule 


module us_tim (
	input clk,
	input n_rst,
	output reg us_is_over
);
reg [5:0] us_timer;
parameter TICKS_IN_1US_FOR_CLK_60M = 60 - 1;

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		us_is_over = 0;
	else
		us_is_over = (us_timer == (TICKS_IN_1US_FOR_CLK_60M - 1));
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		us_timer = 0;
	else if(us_is_over)
		us_timer = 0;
	else 
		us_timer = us_timer + 1;
end
endmodule 



module us_of_ms_tim (
	input  clk,
	input  n_rst,
	input  preset,
	input  [9:0] us_of_ms_preset,
	output reg[9:0] us_of_ms_reg,
	input  us_is_over,
	output reg ms_is_over
);
parameter US_IN_MS = 1000 - 1; 

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ms_is_over = 0;
	else 
		ms_is_over = (us_of_ms_reg == (US_IN_MS - 1));
end

always@(posedge clk or negedge n_rst or posedge preset)
begin
	if(n_rst == 0)
		us_of_ms_reg = 0;
	else if(preset)
		us_of_ms_reg = us_of_ms_preset;
	else if(ms_is_over)
		us_of_ms_reg = 0;
	else if(us_is_over)
		us_of_ms_reg = us_of_ms_reg + 1;
	//else 
	//	us_of_ms_reg = us_of_ms_reg + 1;
end
endmodule 



module ms_of_day_tim (
	input clk,
	input n_rst,
	input preset,
	input [26:0] ms_of_day_preset,
	output reg [26:0] ms_of_day_reg,
	input ms_is_over,
	output reg day_is_over
);
parameter MS_IN_DAY = 86400000 - 1; 

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		day_is_over = 0;
	else 
		day_is_over = (ms_of_day_reg == (MS_IN_DAY - 1));
end

always@(posedge clk or negedge n_rst or posedge preset)
begin
	if(n_rst == 0)
		ms_of_day_reg = 0;
	else if(preset)
		ms_of_day_reg = ms_of_day_preset;
	else if(day_is_over)
		ms_of_day_reg = 0;
	else if(ms_is_over)
		ms_of_day_reg = ms_of_day_reg + 1;
	//else 
	//	ms_of_day_reg = ms_of_day_reg + 1;
end
endmodule 


module day_tim (
	input clk,
	input n_rst,
	input preset,
	input [15:0] day_preset,
	output reg [15:0] day_reg,
	input day_is_over
);
always@(posedge clk or negedge n_rst or posedge preset)
begin
	if(n_rst == 0)
		day_reg = 0;
	else if(preset)
		day_reg = day_preset;
	else if(day_is_over)
		day_reg = day_reg + 1;
	//else
	//	day_reg = day_reg + 1;
end
endmodule


 