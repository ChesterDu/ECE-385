/*Perform sign extention for 11 bits input and output 16 bits value*/
module SEXT_11(input logic [10:0] IN,
					output logic [15:0] OUT);
		
		assign OUT[10:0] = IN;
		assign OUT[15:11] = {5{IN[10]}};

endmodule


/*Perform sign extention for 9 bits input and output 16 bits value*/
module SEXT_9(input logic [8:0] IN,
					output logic [15:0] OUT);
					
		assign OUT[8:0] = IN;
		assign OUT[15:9] = {7{IN[8]}};

endmodule

/*Perform sign extention for 6 bits input and output 16 bits value*/
module SEXT_6(input logic [5:0] IN,
				  output logic [15:0] OUT);
				  
		assign OUT[5:0] = IN;
		assign OUT[15:6] = {10{IN[5]}};

endmodule

/*Perform sign extention for 4 bits input and output 16 bits value*/
module SEXT_5(input logic [4:0] IN,
				  output logic [15:0] OUT);

		assign OUT[4:0] = IN;
		assign OUT[15:5] = {11{IN[4]}};

endmodule