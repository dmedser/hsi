module coder (
	input clk,
	input n_rst,
	input clk_en,
	input [7:0] d,
	input wr_en,
	output reg busy,
	output reg q
); 

parameter OFF = 0,
			 ON  = 1;
			 
parameter START_BIT = 0,
			 STOP_BIT  = 1;
			 
reg [8:0] FRAME_REG;
`define PARITY_BIT FRAME_REG[8] 
		 			 
/********** CODER STATE MACHINE **********/
 			 
reg [2:0] cd_state;
parameter CD_STATE_CTRL 	  = 0,
			 CD_STATE_PISO_CONV = 1;
			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			reset();
		end
	else if(clk_en == ON)
		begin
			case (cd_state)	
			CD_STATE_CTRL:
				begin
					control();
				end
			CD_STATE_PISO_CONV:
				begin
					piso_conversion();
				end
			default:
				begin
					control();
				end
			endcase 
		end
end

/********* PISO CONVERSION TIMER *********/

reg [3:0] tx_time;	
parameter FRAME_TX_TIME = 9;			 

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			tx_time = 0;
		end
	else if(clk_en == ON)
		begin
			if(cd_state == CD_STATE_PISO_CONV)
				begin
					tx_time = tx_time + 1;
				end
			else
				begin
					tx_time = 0;
				end
		end
end

/***************** TASKS *****************/

task reset;
	begin
		busy = OFF;
		FRAME_REG = 0;
		q = STOP_BIT;
		cd_state = CD_STATE_CTRL;
	end
endtask

task control;
	begin
		if(wr_en == ON)
			begin
				busy = ON;
				FRAME_REG[7:0] <= d;
				`PARITY_BIT <= ~(d[7]^d[6]^d[5]^d[4]^d[3]^d[2]^d[1]^d[0]); 
				q = START_BIT;
				cd_state = CD_STATE_PISO_CONV;
			end
		else 
			begin
				busy = OFF;
				FRAME_REG = 0;
				q = STOP_BIT;
				cd_state = CD_STATE_CTRL;
			end
	end
endtask

task piso_conversion;
	begin
		if(tx_time < FRAME_TX_TIME)
			begin
				q = FRAME_REG[0];
				FRAME_REG = (FRAME_REG >> 1);
			end
		else
			begin
				busy = OFF;
				q = STOP_BIT;
				cd_state = CD_STATE_CTRL;
			end
	end
endtask



endmodule