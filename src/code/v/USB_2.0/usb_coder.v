module usb_coder (
	input  clk,
	input  n_rst,
	
	input bus_busy,
	
	input  tx_rdy,
	output reg tx_ack,
	input  last_byte,
	
	input [7:0] d,

	output [7:0] q,
	
	output q_asserted,
	output pck_sent
);


always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tx_ack = 0;
	else
		tx_ack = ~CD_BUSY & ~bus_busy & tx_rdy;
end

crc8_atm_calc CRC8_ATM_CALC (
  .clk(clk),
  .n_rst(CD_BUSY),
  .en(CD_BUSY),    
  .d(q),
  .crc(CRC8)
);
wire[7:0] CRC8; 
 

reg[3:0] ucd_state;
parameter CTRL = 0,
          PHH  = 1,
			 PHL  = 2,
			 ADDR = 3,
			 NUMH = 4,
			 NUML = 5,
			 CRCH = 6,
			 DATA = 7,
			 CRC  = 8;
			 
wire UCD_STATE_CTRL = (ucd_state == CTRL),
	  UCD_STATE_PHH  = (ucd_state == PHH),
	  UCD_STATE_PHL  = (ucd_state == PHL),
	  UCD_STATE_ADDR = (ucd_state == ADDR),
	  UCD_STATE_NUMH = (ucd_state == NUMH),
	  UCD_STATE_NUML = (ucd_state == NUML),
	  UCD_STATE_CRCH = (ucd_state == CRCH),
	  UCD_STATE_DATA = (ucd_state == DATA),
	  UCD_STATE_CRC  = (ucd_state == CRC);
	  
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ucd_state = CTRL;
	else 
		begin
			case(ucd_state)
			CTRL:
				begin
					if(tx_ack)
						ucd_state = PHH;
					else 
						ucd_state = CTRL;
				end
			PHH:  ucd_state = PHL;
			PHL:  ucd_state = ADDR;
			ADDR: ucd_state = NUMH;
			NUMH: ucd_state = NUML;
			NUML: ucd_state = CRCH;
			CRCH: ucd_state = DATA;
			DATA:
				begin
					if(last_byte)
						ucd_state = CRC;
					else 
						ucd_state = DATA;
				end
			CRC:     ucd_state = CTRL;
			default: ucd_state = CTRL;
			endcase
		end
end


assign pck_sent = UCD_STATE_CRC;

wire CD_BUSY = ~UCD_STATE_CTRL;
assign q_asserted = CD_BUSY;

wire UCD_CRC_STATES = UCD_STATE_CRCH | UCD_STATE_CRC;
			  
assign q = UCD_CRC_STATES ? CRC8 : d;


endmodule 