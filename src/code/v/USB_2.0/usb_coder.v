module usb_coder (
	input  clk,
	input  n_rst,
	
	input  tx_rdy,
	
	input  last_byte,
	
	output rd_a,
	output rd_nh,
	output rd_nl,
	output rd_d,
	
	input [7:0] d,

	//output reg [7:0] q,
	output [7:0] q,
	
	output q_asserted,
	output pck_sent
);

assign rd_a  = UCD_STATE_PHH;
assign rd_nh = UCD_STATE_PHL;
assign rd_nl = UCD_STATE_ADDR;
assign rd_d  = UCD_STATE_NUMH | UCD_STATE_NUML | UCD_STATE_CRCH | (UCD_STATE_DATA & ~last_byte_sync);

assign pck_sent = UCD_STATE_CRC;

wire CD_BUSY = ~UCD_STATE_CTRL;
assign q_asserted = CD_BUSY;



crc8_atm_calc CRC8_ATM_CALC (
  .clk(clk),
  .n_rst(CD_BUSY),
  .en(CD_BUSY),    
  .d(q),
  .crc(CRC8)
);
wire[7:0] CRC8; 
 
 
reg last_byte_sync; 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		last_byte_sync = 0;
	else 
		last_byte_sync = last_byte;
end 



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
					if(tx_rdy)
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
					if(last_byte_sync)
						ucd_state = CRC;
					else 
						ucd_state = DATA;
				end
			CRC:     ucd_state = CTRL;
			default: ucd_state = CTRL;
			endcase
		end
end


reg[7:0] d_sync; 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		d_sync = 0;
	else 
		d_sync = d;
end

wire UCD_PAYLOAD_STATES = UCD_STATE_ADDR | UCD_STATE_NUMH | UCD_STATE_NUML | UCD_STATE_DATA,
     UCD_CRC_STATES = UCD_STATE_CRCH | UCD_STATE_CRC;


wire[7:0] Q_PHH_MASK     = UCD_STATE_PHH      ? 8'hFF : 0,
          Q_PHL_MASK     = UCD_STATE_PHL      ? 8'hFF : 0,
	       Q_PAYLOAD_MASK = UCD_PAYLOAD_STATES ? 8'hFF : 0,
			 Q_CRC_MASK     = UCD_CRC_STATES     ? 8'hFF : 0;
			  
assign q = (Q_PHH_MASK & 8'h5E) | (Q_PHL_MASK & 8'h4D) | (Q_PAYLOAD_MASK & d_sync) | (Q_CRC_MASK & CRC8);


endmodule 