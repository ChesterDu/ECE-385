
/* 16 bit poseedge register*/
module register_16 (input  logic Clk, LD, Reset,
						  input  logic [15:0] IN,
						  output logic [15:0] data_out);
					
			always_ff @ (posedge Clk or negedge Reset)
			begin
				if (~Reset)				// clear on reset
					data_out <= 16'h0;
				else if (LD)		// load the data if LD is high
					data_out <= IN;
			end

endmodule


// module for REG FILE
module REG_FILE (input logic  Clk, LD, Reset,
					  input logic[2:0] SR1, SR2, DR,
					  input logic[15:0] IN,
					  output logic[15:0] SR1_OUT, SR2_OUT);
					  
	logic LD0,LD1,LD2,LD3,LD4,LD5,LD6,LD7 = 0;			
	logic[15:0] OUT0, OUT1, OUT2, OUT3, OUT4, OUT5, OUT6, OUT7;
	
	// create 8 registers	  
	register_16 R0 (.Clk(Clk), .LD(LD0), .Reset(Reset), .IN(IN), .data_out(OUT0) );		
	register_16 R1 (.Clk(Clk), .LD(LD1), .Reset(Reset), .IN(IN), .data_out(OUT1) );	
	register_16 R2 (.Clk(Clk), .LD(LD2), .Reset(Reset), .IN(IN), .data_out(OUT2) );	
	register_16 R3 (.Clk(Clk), .LD(LD3), .Reset(Reset), .IN(IN), .data_out(OUT3) );	
	register_16 R4 (.Clk(Clk), .LD(LD4), .Reset(Reset), .IN(IN), .data_out(OUT4) );	
	register_16 R5 (.Clk(Clk), .LD(LD5), .Reset(Reset), .IN(IN), .data_out(OUT5) );	
	register_16 R6 (.Clk(Clk), .LD(LD6), .Reset(Reset), .IN(IN), .data_out(OUT6) );	
	register_16 R7 (.Clk(Clk), .LD(LD7), .Reset(Reset), .IN(IN), .data_out(OUT7) );	
	
	always_comb
	begin
		// initial all LD to zero
		LD0 = 0;
		LD1 = 0;
		LD2 = 0;
		LD3 = 0;
		LD4 = 0;
		LD5 = 0;
		LD6 = 0;
		LD7 = 0;
	
	if (LD)
	// Load bits from data bus into registers
	begin
		case(DR)
			3'b000: LD0=1;
			3'b001: LD1=1;
			3'b010: LD2=1;
			3'b011: LD3=1;
			3'b100: LD4=1;
			3'b101: LD5=1;
			3'b110: LD6=1;
			3'b111: LD7=1;
		endcase
	end
	

	// output bits from corresponding registers 
	// choose for outputs
	case(SR1)
		// SR1
		3'b000: SR1_OUT=OUT0;
		3'b001: SR1_OUT=OUT1;
		3'b010: SR1_OUT=OUT2;
		3'b011: SR1_OUT=OUT3;
		3'b100: SR1_OUT=OUT4;
		3'b101: SR1_OUT=OUT5;
		3'b110: SR1_OUT=OUT6;
		3'b111: SR1_OUT=OUT7;
	endcase
	case(SR2)
		// SR1
		3'b000: SR2_OUT=OUT0;
		3'b001: SR2_OUT=OUT1;
		3'b010: SR2_OUT=OUT2;
		3'b011: SR2_OUT=OUT3;
		3'b100: SR2_OUT=OUT4;
		3'b101: SR2_OUT=OUT5;
		3'b110: SR2_OUT=OUT6;
		3'b111: SR2_OUT=OUT7;	
	endcase
	
	end	  
					  
endmodule


