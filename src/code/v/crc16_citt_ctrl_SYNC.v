module crc16_citt_ctrl (
	input clk,
	input n_rst,
	input [7:0] d,
	input d_rdy,
	input msg_end,
	output [15:0] crc, 
	output crc_rdy
);
			 
assign crc_rdy = msg_end;

crc16_citt_calc CRC16_CITT_CALC (
	.clk(clk),
	.n_rst(n_rst & ~(crc_status == CRC_STATUS_RESET)),
	.en(d_rdy || (crc_status == CRC_STATUS_CALC)),
	.d8(d),
	.start(d_rdy),
	.crc(crc),
	.crc_updated(CRC_UPDATED)
);

reg[2:0] crc_status;
parameter CRC_STATUS_CTRL    = 0,
			 CRC_STATUS_PREPARE = 1,
			 CRC_STATUS_CALC    = 2,
			 CRC_STATUS_READY   = 3,
			 CRC_STATUS_RESET   = 4;			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		begin
			crc_status = CRC_STATUS_CTRL; 
		end
	else
		begin
			case(crc_status)
			CRC_STATUS_CTRL:
				begin
					if(d_rdy)
						begin
							crc_status = CRC_STATUS_CALC;
						end
					else if(msg_end)	
						begin
							crc_status = CRC_STATUS_RESET;
						end	
					else
						begin
							crc_status = CRC_STATUS_CTRL;
						end
				end
			CRC_STATUS_CALC:
				begin
					if(CRC_UPDATED)
						begin
							crc_status = CRC_STATUS_CTRL;
						end
					else
						begin
							crc_status = CRC_STATUS_CALC;
						end
				end
			CRC_STATUS_RESET:
				begin
					crc_status = CRC_STATUS_CTRL;
				end
			default:
				begin
				
				end
			endcase
		end
end
  
endmodule 
