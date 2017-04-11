module decoder (
	input clk,
	input n_rst,
	input clk_en,
	input d,
	output  [7:0] q,
	output  q_rdy,
	output  pb_err,
	output frame_end
);

`include "src/code/vh/hsi_config.vh"	
	
parameter OFF = 0,
			 ON  = 1,
			 START_BIT = 0,
			 STOP_BIT  = 1,
			 CONVERSION_TIME 	  = 80,
			 MSG_END_CHECK_TIME = 86;
			 			 
wire[6:0] SIPO_TIME;
wire SIPO_CONVERSION_IS_OVER = (SIPO_TIME == CONVERSION_TIME);
wire ITS_MSG_END_CHECK_TIME = (SIPO_TIME == MSG_END_CHECK_TIME);
wire [6:0] SAMPLE_TIME;
wire [3:0] FRAME_IDX;

assign q = (`ML_FST == `LSB) ? FRAME_REG[7:0] : FRAME_REG[8:1];

`define PARITY_BIT_H FRAME_REG[8]
`define PARITY_BIT_L FRAME_REG[0]

wire PARITY_BIT_SRC = (`ML_FST == `LSB) ? `PARITY_BIT_H : `PARITY_BIT_L;
wire PARITY_BIT_VAL = (`ML_FST == `LSB) ? ~(FRAME_REG[7]^FRAME_REG[6]^FRAME_REG[5]^FRAME_REG[4]^FRAME_REG[3]^FRAME_REG[2]^FRAME_REG[1]^FRAME_REG[0]) :
												      ~(FRAME_REG[8]^FRAME_REG[7]^FRAME_REG[6]^FRAME_REG[5]^FRAME_REG[4]^FRAME_REG[3]^FRAME_REG[2]^FRAME_REG[1]);

wire PARITY_BIT_CORRECT = (PARITY_BIT_SRC == PARITY_BIT_VAL);														
assign q_rdy = (SIPO_CONVERSION_IS_OVER & PARITY_BIT_CORRECT) ? ON : OFF; 
assign pb_err = (SIPO_CONVERSION_IS_OVER & ~PARITY_BIT_CORRECT) ? ON : OFF; 										
									
sipo_timer SIPO_TIM (
	.clk(clk),
	.clk_en(clk_en),
	.n_rst(n_rst & FRAME_RX_EN),
	.sipo_time(SIPO_TIME)
);

dc_sample_ctrl DC_SAMPLE_CTRL (
	.incr(ITS_SAMPLE_TIME),
	.n_rst(n_rst & ~(dc_state == DC_STATE_CTRL)),
	.t_sample(SAMPLE_TIME),
	.fr_idx(FRAME_IDX)
);		

assign frame_end = ITS_MSG_END_CHECK_TIME & (d == STOP_BIT);
				
/********** DECODER STATE MACHINE **********/
			 
reg [1:0] dc_state;
parameter DC_STATE_CTRL 	  = 0,
			 DC_STATE_SIPO_CONV = 1;		 
			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			dc_state = DC_STATE_CTRL;
		end
	else if(clk_en == ON)
		begin
			case(dc_state)
			DC_STATE_CTRL:
				begin
					if(d == START_BIT)
						begin
							dc_state = DC_STATE_SIPO_CONV;
						end
					else 
						begin
							dc_state = DC_STATE_CTRL;
						end
				end
			DC_STATE_SIPO_CONV:
				begin
					if(SIPO_CONVERSION_IS_OVER)
						begin
							dc_state = DC_STATE_CTRL;
						end
					else	
						begin
							dc_state = DC_STATE_SIPO_CONV;
						end
					end
			default:
				begin
					
				end
			endcase
		end
end

reg FRAME_RX_EN;	
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			FRAME_RX_EN = OFF;
		end
	else if (clk_en == 1)
		begin
			if(dc_state == DC_STATE_SIPO_CONV)
				begin
					FRAME_RX_EN = ON;
				end
			else if(ITS_MSG_END_CHECK_TIME)
				begin
					FRAME_RX_EN = OFF;
				end
		end
end

reg [8:0] FRAME_REG;
reg ITS_SAMPLE_TIME;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			ITS_SAMPLE_TIME = OFF;
			FRAME_REG = 0;
		end
	else if(clk_en == ON)
		begin
			if((dc_state == DC_STATE_SIPO_CONV) & (SIPO_TIME == SAMPLE_TIME)) 
				begin
					if(`ML_FST == `LSB)
						begin
							ITS_SAMPLE_TIME = ON;
							FRAME_REG[FRAME_IDX] = d;
						end
					else
						begin
							ITS_SAMPLE_TIME = ON;
							FRAME_REG[8 - FRAME_IDX] = d;
						end
				end
			else 
				begin
					ITS_SAMPLE_TIME = OFF; 
				end
		end
end
			
endmodule

module sipo_timer (
	input clk,
	input clk_en,
	input n_rst,
	output reg [6:0] sipo_time
);

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			sipo_time = 0;
		end
	else if(clk_en == 1)
		begin
			sipo_time = sipo_time + 1;
		end
end

endmodule 

module dc_sample_ctrl (
	input incr,
	input n_rst,
	output reg [6:0] t_sample,
	output reg [3:0] fr_idx
); 

always@(posedge incr or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			t_sample = 8;
			fr_idx = 0;
		end
	else 
		begin
			t_sample = t_sample + 8;
			fr_idx = fr_idx + 1;
		end
end

endmodule 