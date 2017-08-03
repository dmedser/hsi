module hsi_monitor_reader (
	input clk,
	input n_rst,
	
	output reg tx_rdy,
	input tx_ack,
	input rd_rdy,
	
	output reg rdreq,
	
	input[10:0] usedw,
	
	output reg last_byte,
	
	input [7:0] d,
	input last_frame_src,
	output reg[7:0] q
);

`define MSTR_MNTR_ADDR 8'h0B
`define SLV_MNTR_ADDR  8'h09

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		tx_rdy = 0;
	else if(tx_ack)
		tx_rdy = 0;
	else if(rd_rdy)
		tx_rdy = 1;
end

reg[10:0] usedw_reg;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		usedw_reg = 0;
	else if(rd_rdy) 
		usedw_reg = usedw;
end

wire[7:0] USEDW_H,
			 USEDW_L;

assign USEDW_H[7:3] = 0; 
assign USEDW_H[2:0] = usedw_reg[10:8];

assign USEDW_L = usedw_reg[7:0];

wire[7:0] ADDR = last_frame_src ? `SLV_MNTR_ADDR : `MSTR_MNTR_ADDR;

reg bc_en;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		bc_en = 0;
	else if(bc == 4) 
		bc_en = 0;
	else if(tx_ack)
		bc_en = 1;
end

reg[2:0] bc;
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		bc = 0;
	else if(bc_en) 
		bc = bc + 1;
	else if(last_byte)
		bc = 0;
end
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		q = 0;
	else 
		begin
			case(bc)
			0: q = bc_en ? 8'h4D : 8'h5E;
			1: q = ADDR;
			2: q = USEDW_H;
			3: q = USEDW_L;
			default: q = d;
			endcase
		end
end

wire stop_rd = (rdreq & (usedw == 0));

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		rdreq = 0;
	else if(stop_rd)
		rdreq = 0;
	else if(bc == 3) 
		rdreq = 1;
end

always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		last_byte = 0;
	else 
		last_byte = stop_rd;
end


endmodule 