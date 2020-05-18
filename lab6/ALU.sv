
/* ALU component */
module ALU(input  logic [15:0] A, B,
			  input  logic [1:0] ALUK, 
			  output logic [15:0] OUT);

	always_comb
	begin
		// select operation based on ALUK
		case(ALUK)
			2'b00: OUT = A + B;
			2'b01: OUT = A & B;
			2'b10: OUT = ~A;
			2'b11: OUT = A;
		endcase
	end


endmodule