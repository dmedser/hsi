module decoder (
	input clk,
	input n_rst,
	input d,
	output reg [7:0] q,
	output reg q_rdy,
	output reg err,
	output reg msg_end
);

parameter LSB_FST = 0,
			 MSB_FST = 1;

parameter ml_fst = LSB_FST;

parameter OFF = 0,
			 ON  = 1;

parameter START_BIT = 0,
			 STOP_BIT  = 1; 
			 
			
/********** DECODER STATE MACHINE **********/
			 
reg [1:0] dc_state;
parameter DC_STATE_CTRL 	  = 0,
			 DC_STATE_SIPO_CONV = 1;		 
			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			reset();
		end
	else
		begin
			case(dc_state)
			DC_STATE_CTRL:
				begin
					control();
				end
			DC_STATE_SIPO_CONV:
				begin
					sipo_conversion();
				end
			default:
				begin
					control();
				end
			endcase
		end
end

/********** SIPO CONVERSION TIMER **********/
		 
reg[6:0] rx_time;
parameter FRAME_RX_TIME = 80;

always@(posedge clk)
begin
	if(n_rst == 0)
		begin
			rx_time = 0;
		end
	else
		begin 
			if(FRAME_RX_EN == ON)
				begin
					rx_time = rx_time + 1;
				end
			else 
				begin
					rx_time = 0;
				end
		end
end			


reg MSG_END_CHECK_TIMER_EN;
reg [1:0] mec_time; 	// Message End Check Time
parameter MSG_END_CHECK_TIME = 3;

/***************** TASKS *****************/

reg FRAME_RX_EN;	
reg [8:0] FRAME_REG;

task reset;
	begin
		FRAME_RX_EN = OFF;
		MSG_END_CHECK_TIMER_EN = OFF;
		msg_end = OFF;
		q = 0;
		FRAME_REG = 0;
		q_rdy = OFF;
		err = OFF;
		t_sample = 8;
		fr_idx = 0;
		dc_state = DC_STATE_CTRL;
	end
endtask


task control;
	begin
		if(d == START_BIT)
			begin
				FRAME_RX_EN = ON;
				MSG_END_CHECK_TIMER_EN = OFF;
				msg_end = OFF;
				q = 0;
				FRAME_REG = 0;
				q_rdy = OFF;
				err = OFF;
				dc_state = DC_STATE_SIPO_CONV;
			end
		else 
			begin
				if(mec_time == MSG_END_CHECK_TIME)
					begin
						msg_end = ON;
						MSG_END_CHECK_TIMER_EN = OFF;
					end
				else
					begin
						msg_end = OFF;
						q = 0;
						FRAME_REG = 0;
						q_rdy = OFF;
						err = OFF;
						dc_state = DC_STATE_CTRL;
					end
			end
	end
endtask


always@(posedge clk)
begin
	if(n_rst == 0)
		begin
			mec_time = 0;
		end
	else if(MSG_END_CHECK_TIMER_EN == ON)
		begin
			if(mec_time < MSG_END_CHECK_TIME)
				begin
					mec_time = mec_time + 1;
				end
			else
				begin
					mec_time = 0;
				end
		end
	else
		begin
			mec_time = 0;
		end
end

reg [6:0] t_sample;
reg [3:0] fr_idx;

task sipo_conversion;
	begin
		if(rx_time < FRAME_RX_TIME)
			begin
				if(rx_time == t_sample)
					begin
						if(ml_fst == LSB_FST)
							begin
								FRAME_REG[fr_idx] = d;
								fr_idx = fr_idx + 1;
								t_sample = t_sample + 8;
							end
						else
							begin
								FRAME_REG[8 - fr_idx] = d;
								fr_idx = fr_idx + 1;
								t_sample = t_sample + 8;
							end
					end
			end
		else
			begin
				if(ml_fst == LSB_FST)
					begin
						if(FRAME_REG[8] == ~(FRAME_REG[7]^FRAME_REG[6]^FRAME_REG[5]^FRAME_REG[4]^FRAME_REG[3]^FRAME_REG[2]^FRAME_REG[1]^FRAME_REG[0]))
							begin
								fr_idx = 0;
								t_sample = 8;
								q = FRAME_REG[7:0];
								q_rdy = ON;
								err = OFF;
								FRAME_RX_EN = OFF;
								MSG_END_CHECK_TIMER_EN = ON;
								dc_state = DC_STATE_CTRL;
							end
						else	
							begin
								fr_idx = 0;
								t_sample = 8;
								q = 0;
								q_rdy = OFF;
								err = ON;
								FRAME_RX_EN = OFF;
								MSG_END_CHECK_TIMER_EN = OFF;
								dc_state = DC_STATE_CTRL;
							end
					end
				else 
					begin
						if(FRAME_REG[0] == ~(FRAME_REG[8]^FRAME_REG[7]^FRAME_REG[6]^FRAME_REG[5]^FRAME_REG[4]^FRAME_REG[3]^FRAME_REG[2]^FRAME_REG[1]))
							begin
								fr_idx = 0;
								t_sample = 8;
								q = FRAME_REG[8:1];
								q_rdy = ON;
								err = OFF;
								FRAME_RX_EN = OFF;
								MSG_END_CHECK_TIMER_EN = ON;
								dc_state = DC_STATE_CTRL;
							end
						else	
							begin
								fr_idx = 0;
								t_sample = 8;
								q = 0;
								q_rdy = OFF;
								err = ON;
								FRAME_RX_EN = OFF;
								MSG_END_CHECK_TIMER_EN = OFF;
								dc_state = DC_STATE_CTRL;
							end
					end
			end
	end
endtask
			
			
endmodule