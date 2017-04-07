module hsi_s_tx_ctrl (
	input clk,
	input clk_en,
	input n_rst,
	input sd_busy,
	input sr,
	output dat1,
	output dat2,
	input rx_msg_end,
	input rx_err,
	input [7:0] rx_flag
);

coder CD (
	.clk(clk),
	.n_rst(n_rst),
	.clk_en(clk_en),
	.d(TX_D),
	.d_rdy(TX_D_RDY),
	.busy(CD_BUSY),
	.q(CD_Q)
);

assign dat1 = CD_Q;
assign dat2 = CD_Q;

//always@(posedge clk or negedge n_rst)
//begin
//	if(n_rst == 0)
//		begin
//		
//		end
//	else if(ERR_OK)
//		begin
//			case(FLAG):
//			`FLAG_STATUS_REQUEST:
//				begin
//				
//				end
//			`FLAG_DATA_PACKET_REQUEST:
//				begin
//				
//				end
//			`FLAG_CONTROL_COMMAND_WORD:
//				begin
//				
//				end
//			default:
//				begin
//				
//				end
//			endcase
//		end
//	else 
//		begin
//			
//		end
//end
endmodule