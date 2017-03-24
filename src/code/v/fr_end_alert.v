module frame_end_alert (
	input clk,
	input [4:0] me_ctrls,
	input me_crc,
	output [4:0] fe 
);
assign fe[0] = tmp[0] & me_crc;
assign fe[1] = tmp[1] & me_crc;
assign fe[2] = tmp[2] & me_crc;
assign fe[3] = tmp[3] & me_crc;
assign fe[4] = tmp[4] & me_crc;

reg[4:0] tmp;
always@(posedge clk)
begin
	if(me_crc)
		tmp[0] = 0;
	else 
		begin
			if(me_ctrls[0])
				tmp[0] = 1;	
		end
end

always@(posedge clk)
begin
	if(me_crc)
		tmp[1] = 0;
	else 
		begin
			if(me_ctrls[1])
				tmp[1] = 1;	
		end
end

always@(posedge clk)
begin
	if(me_crc)
		tmp[2] = 0;
	else 
		begin
			if(me_ctrls[2])
				tmp[2] = 1;	
		end
end

always@(posedge clk)
begin
	if(me_crc)
		tmp[3] = 0;
	else 
		begin
			if(me_ctrls[3])
				tmp[3] = 1;	
		end
end

always@(posedge clk)
begin
	if(me_crc)
		tmp[4] = 0;
	else 
		begin
			if(me_ctrls[4])
				tmp[4] = 1;	
		end
end
endmodule 