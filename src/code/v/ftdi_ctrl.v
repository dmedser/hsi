module ftdi_controller (
	input   clk,
	input   n_rst,
	output  reg oe,
	input   rxf,
	output  reg rd,
	input   txe,
	output  wr
);

//parameter OFF = 0,
//			 ON  = 1;
//			 
//reg [1:0] fc_state;
//parameter FC_STATE_CTRL 		= 0, 
//			 FC_STATE_RD_PREPARE = 1,
//			 FC_STATE_RD_BYTE		= 2,
//			 FC_STATE_WR			= 3;
//	
///************** FTDI CONTROLLER STATE MACHINE **************/
//always@(posedge clk or negedge n_rst)
//begin
//	if(n_rst == 0)
//		begin	
//			reset();
//		end
//	else 
//		begin
//			case(fc_state)
//				FC_STATE_CTRL:
//					begin
//						control();
//					end
//				FC_STATE_RD_PREPARE: 
//					begin
//						read_prepare();
//					end
//				FC_STATE_RD_BYTE:
//					begin
//						read_byte();
//					end
//				FC_STATE_WR:
//					begin
//						write();
//					end
//				default : 	
//					begin
//						control();
//					end
//			endcase
//		end
//end
//
//
//task reset;
//	begin
//		oe   = 1;
//		rd   = 1;
//		q_asserted = OFF;
//		fc_state = FC_STATE_CTRL;
//	end
//endtask
//
//
//task control;
//	begin
//		if(rxf == 0)
//			begin
//				oe = 0;
//				fc_state = FC_STATE_RD_PREPARE;
//			end
//		else if(txe == 0)
//			begin
//				if(fifo_tx_rdy == ON)
//					begin
//						oe = 1;
//						fc_state = FC_STATE_WR;
//					end
//				else	
//					begin
//						oe = 1;
//						fc_state = FC_STATE_CTRL;
//					end
//			end
//		else
//			begin
//				oe = 1;
//				fc_state = FC_STATE_CTRL;
//			end
//	end
//endtask
//
//
//task read_prepare;
//	begin
//		rd = 0;
//		q_asserted = ON;
//		fc_state = FC_STATE_RD_BYTE;
//	end
//endtask
//
//
//task read_byte;
//	begin
//		rd = 1;
//		oe = 1;
//		q_asserted = OFF;
//		fc_state = FC_STATE_CTRL;
//	end
//endtask
//
//
//task write;
//	begin
//		if(fifo_tx_rdy == OFF) 
//		//if(rx_tx_rdy == OFF)
//			begin
//				fc_state = FC_STATE_CTRL;
//			end
//		else
//			begin
//				fc_state = FC_STATE_WR;
//			end
//	end	
//endtask
//
//assign ftdi_rx_rdy = (fifo_tx_rdy == ON) && (txe == 0) && (fc_state == FC_STATE_WR);
//
//wire rx_tx_rdy = (ftdi_rx_rdy == ON) && (fifo_tx_rdy == ON);
//
//assign wr = (rx_tx_rdy == ON) ? sync_wr : 1;
//
//reg sync_wr;
//
//always@(posedge clk)
//begin
//	if(n_rst == 0)
//		begin
//			sync_wr = 1;
//		end
//	else if(fifo_tx_rdy == ON)
//		begin
//			if(ftdi_rx_rdy == ON)
//				begin
//					sync_wr = 0;
//				end
//		end
//	else
//		begin
//			sync_wr = 1;
//		end
//end



endmodule 