module usb_coder_connector (
	input clk,
	input n_rst,
	
	input [63:0] st_bytes,
	
	input [15:0] sdi_bytes,
	
	input [23:0] csi_bytes,
		
	output [7:0] q,
	output q_rdy,
	input  q_rdy_ack,
	
	input start_commutation,
	
	input byte_sent
);

wire[7:0] st_b1 = st_bytes[63:56], st_b5 = st_bytes[31:24],
  		    st_b2 = st_bytes[55:48], st_b6 = st_bytes[23:16],
		    st_b3 = st_bytes[47:40], st_b7 = st_bytes[15:8],
		    st_b4 = st_bytes[39:32], st_b8 = st_bytes[7:0];
			  
wire[7:0] sdi_b1 = sdi_bytes[15:8],
			 sdi_b2 = sdi_bytes[7:0];
			  
wire[7:0] csi_b1 = csi_bytes[23:16],
	       csi_b2 = csi_bytes[15:8],
	       csi_b3 = csi_bytes[7:0];
			 
reg[3:0] ucc_state;
parameter CTRL = 0,
			 
			 ST1 = 1, ST5 = 5,
			 ST2 = 2, ST6 = 6,
			 ST3 = 3, ST7 = 7,
			 ST4 = 4, ST8 = 8,
			 
			 SDI1 = 9,
			 SDI2 = 10,
			 SDI3 = 11,
			 
			 CSI1 = 12,
			 CSI2 = 13,
			 CSI3 = 14;

wire UCC_STATE_CTRL = (ucc_state == CTRL),
	  
	  UCC_STATE_ST1 = (ucc_state == ST1), UCC_STATE_ST5 = (ucc_state == ST5),
	  UCC_STATE_ST2 = (ucc_state == ST2), UCC_STATE_ST6 = (ucc_state == ST6),
	  UCC_STATE_ST3 = (ucc_state == ST3), UCC_STATE_ST7 = (ucc_state == ST7),
	  UCC_STATE_ST4 = (ucc_state == ST4), UCC_STATE_ST8 = (ucc_state == ST8),
	  
	  UCC_STATE_SDI1 = (ucc_state == SDI1),
	  UCC_STATE_SDI2 = (ucc_state == SDI2),
	  
	  UCC_STATE_CSI1 = (ucc_state == CSI1),
	  UCC_STATE_CSI2 = (ucc_state == CSI2),
	  UCC_STATE_CSI3 = (ucc_state == CSI3);
			 
always@(posedge clk or negedge n_rst)
begin
	if(n_rst == 0)
		ucc_state = CTRL;
	else 
		begin
			case(ucc_state)
			CTRL: 
				begin
					if(start_commutation)
						ucc_state = ST1;
					else 
						ucc_state = CTRL;
				end
			ST1: ucc_state = ST2;
			ST2: ucc_state = ST3;
			ST3: ucc_state = ST4;
			ST4: ucc_state = ST5;
			ST5: ucc_state = ST6;
			ST6: ucc_state = ST7;
			ST7: ucc_state = ST8;
			ST8: ucc_state = SDI1;
			SDI1: ucc_state = SDI2;
			SDI2: ucc_state = SDI3;
			SDI3: ucc_state = CSI1;
			CSI1: ucc_state = CSI2;
			CSI2: ucc_state = CSI3;
			CSI3: ucc_state = CTRL;
			default:
				begin
				end
			endcase
		end
end


byte_conjunctor ST1_CNJ (
	.b_in1(UCC_STATE_ST1 ? 8'hFF : 0),
	.b_in2(st_b1),
	.b_out(ST1_MASKED)
);
byte_conjunctor ST2_CNJ (
	.b_in1(UCC_STATE_ST2 ? 8'hFF : 0),
	.b_in2(st_b2),
	.b_out(ST2_MASKED)
);
byte_conjunctor ST3_CNJ (
	.b_in1(UCC_STATE_ST3 ? 8'hFF : 0),
	.b_in2(st_b3),
	.b_out(ST3_MASKED)
);
byte_conjunctor ST4_CNJ (
	.b_in1(UCC_STATE_ST4 ? 8'hFF : 0),
	.b_in2(st_b4),
	.b_out(ST4_MASKED)
);
byte_conjunctor ST5_CNJ (
	.b_in1(UCC_STATE_ST5 ? 8'hFF : 0),
	.b_in2(st_b5),
	.b_out(ST5_MASKED)
);
byte_conjunctor ST6_CNJ (
	.b_in1(UCC_STATE_ST6 ? 8'hFF : 0),
	.b_in2(st_b6),
	.b_out(ST6_MASKED)
);
byte_conjunctor ST7_CNJ (
	.b_in1(UCC_STATE_ST7 ? 8'hFF : 0),
	.b_in2(st_b7),
	.b_out(ST7_MASKED)
);
byte_conjunctor ST8_CNJ (
	.b_in1(UCC_STATE_ST8 ? 8'hFF : 0),
	.b_in2(st_b8),
	.b_out(ST8_MASKED)
);

byte_conjunctor SDI1_CNJ (
	.b_in1(UCC_STATE_SDI1 ? 8'hFF : 0),
	.b_in2(sdi_b1),
	.b_out(SDI1_MASKED)
);
byte_conjunctor SDI2_CNJ (
	.b_in1(UCC_STATE_SDI2 ? 8'hFF : 0),
	.b_in2(sdi_b2),
	.b_out(SDI2_MASKED)
);

byte_conjunctor CSI1_CNJ (
	.b_in1(UCC_STATE_CSI1 ? 8'hFF : 0),
	.b_in2(csi_b1),
	.b_out(CSI1_MASKED)
);
byte_conjunctor CSI2_CNJ (
	.b_in1(UCC_STATE_CSI2 ? 8'hFF : 0),
	.b_in2(csi_b2),
	.b_out(CSI2_MASKED)
);
byte_conjunctor CSI3_CNJ (
	.b_in1(UCC_STATE_CSI3 ? 8'hFF : 0),
	.b_in2(csi_b3),
	.b_out(CSI3_MASKED)
);


wire[7:0] ST1_MASKED, ST5_MASKED, 
		    ST2_MASKED, ST6_MASKED,
			 ST3_MASKED, ST7_MASKED,
			 ST4_MASKED, ST8_MASKED,
			 
			 SDI1_MASKED,
			 SDI2_MASKED,
			 
			 CSI1_MASKED,
			 CSI2_MASKED,
			 CSI3_MASKED;

bytes_disjunctor BYTES_DSJ (
	.b_in1(ST1_MASKED),  .b_in2(ST2_MASKED),   .b_in3(ST3_MASKED),   .b_in4(ST4_MASKED),
	.b_in5(ST5_MASKED),  .b_in6(ST6_MASKED),   .b_in7(ST7_MASKED),   .b_in8(ST8_MASKED),
	.b_in9(SDI1_MASKED), .b_in10(SDI2_MASKED), .b_in11(CSI1_MASKED), .b_in12(CSI2_MASKED),
	.b_in13(CSI3_MASKED),
	.b_out(q)
);
			 
endmodule

module byte_mask (
	input  set,
	output [7:0] q 
);
assign q = set ? 8'hFF : 0;
endmodule 

module byte_conjunctor (
	input  [7:0] b_in1,
	input  [7:0] b_in2,
	output [7:0] b_out
);
assign b_out = b_in1 & b_in2;
endmodule  


module bytes_disjunctor (
	input [7:0] b_in1, b_in2,  b_in3,  b_in4,
					b_in5, b_in6,  b_in7,  b_in8, 
					b_in9, b_in10, b_in11, b_in12,
					b_in13,
	output [7:0] b_out
);
assign b_out = b_in1 | b_in2  | b_in3  | b_in4  |
               b_in6 | b_in6  | b_in7  | b_in8  |
               b_in9 | b_in10 | b_in11 | b_in12 |
               b_in13;
endmodule
