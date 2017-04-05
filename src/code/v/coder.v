module coder (
	input clk,
	input n_rst,
	input clk_en,
	input [7:0] d,
	input d_rdy,
	output busy,
	output q
); 

`include "src/code/vh/hsi_config.vh"		

assign busy = (cd_state == CD_STATE_PISO_CONV);		 

wire q_src = (`ML_FST == `LSB) ? FRAME_REG[0] : FRAME_REG[10];
assign q = (cd_state == CD_STATE_PISO_CONV) ? q_src : STOP_BIT;

piso_timer PISO_TIM (
	.clk(clk),
	.clk_en(clk_en),
	.n_rst(n_rst & (cd_state == CD_STATE_PISO_CONV)),
	.conv_is_over(PISO_CONVERSION_IS_OVER)
);
			 
/********** CODER STATE MACHINE **********/
 			 
reg [2:0] cd_state;
parameter CD_STATE_CTRL 	  			 = 0,
			 CD_STATE_PISO_CONV_PREPARE = 1,
			 CD_STATE_PISO_CONV 			 = 2;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		cd_state = CD_STATE_CTRL;
	else if(clk_en == 1)
		begin
			case(cd_state)	
			CD_STATE_CTRL:
				begin
					if(d_rdy == 1)
						cd_state = CD_STATE_PISO_CONV;
					else
						cd_state = CD_STATE_CTRL;
				end
			CD_STATE_PISO_CONV:
				begin
					if(PISO_CONVERSION_IS_OVER)
						cd_state = CD_STATE_CTRL;
					else
						cd_state = CD_STATE_PISO_CONV;
				end
			default:
				begin
				
				end
			endcase 
		end
end


reg [10:0] FRAME_REG;		 			 
parameter START_BIT = 0,
			 STOP_BIT  = 1;	

`define PARITY_BIT (~(d[7]^d[6]^d[5]^d[4]^d[3]^d[2]^d[1]^d[0]))
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			FRAME_REG = 8'hFF;
		end
	else if(clk_en == 1)
		begin
			if(d_rdy == 1)
				begin
					if(`ML_FST == `LSB)
						begin
							FRAME_REG[0] = START_BIT;
							FRAME_REG[8:1] = d;
							FRAME_REG[9] = `PARITY_BIT;
							FRAME_REG[10] = STOP_BIT;
						end 
					else
						begin
							FRAME_REG[10] = START_BIT;
							FRAME_REG[9:2] = d;
							FRAME_REG[1] = `PARITY_BIT;
							FRAME_REG[0] = STOP_BIT;
						end
				end
			else if(cd_state == CD_STATE_PISO_CONV)	
				begin	
					if(`ML_FST == `LSB)
						FRAME_REG = (FRAME_REG >> 1);
					else 
						FRAME_REG = (FRAME_REG << 1);
				end
		end
end


endmodule

module piso_timer (
	input clk,
	input clk_en,
	input n_rst,
	output conv_is_over
);

parameter PISO_CONVERSION_TIME = 9;
assign conv_is_over = (ticks == PISO_CONVERSION_TIME);
reg[3:0] ticks;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ticks = 0;
	else if(clk_en == 1)
		ticks = ticks + 1;
end

endmodule 
