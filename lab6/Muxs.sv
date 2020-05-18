/*2 to 1 MUX with input [2:0]*/
module MUX_2_to_1_bit_3 (input  logic [2:0] IN0, IN1,
						   input		 logic 	 Select,		
							output logic [2:0] OUT);
		
		always_comb
		begin
			if (Select)
				OUT = IN1;
			else
				OUT = IN0;
		end
		
endmodule

/*2 to 1 MUX with input [15:0]*/
module MUX_2_to_1_bit_16 (input  logic [15:0] IN0, IN1,
							 input  logic 	 Select,		
							 output logic [15:0] OUT);
		
		always_comb
		begin
			if (Select)
				OUT = IN1;
			else
				OUT = IN0;
		end
		
endmodule

/*4 to 1 MUX with input [15:0]*/
module MUX_4_to_1_bit_16 (input  logic [15:0] IN0, IN1, IN2, IN3,
							 input  logic [1:0]	Select,		
							 output logic [15:0] OUT);
		
		always_comb
		begin
			case(Select)
				2'b00:
					OUT = IN0;
				2'b01:
					OUT = IN1;
				2'b10:
					OUT = IN2;
				2'b11:
					OUT = IN3;
			endcase
		end
		
endmodule
