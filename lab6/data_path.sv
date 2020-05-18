// connect all components together
module datapath(  

			// normal inputs
			input  logic Clk, Reset,
			
			// inputs for register file
			input logic[2:0] SR2,
				
			// Load sig for registers
			input logic    LD_MAR,
								LD_MDR,
								LD_IR,
								LD_BEN,
								LD_CC,
								LD_REG,
								LD_PC,
								LD_LED, // for PAUSE instruction
								
			// Gate sig 
			input logic    GatePC,
								GateMDR,
								GateALU,
								GateMARMUX,
								
			// select sig for MUXes
			input logic [1:0]  PCMUX,
			input logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
			input logic [1:0]  	ADDR2MUX,
										ALUK,

			// input from memory
			input logic[15:0] Data_to_CPU,
			input logic MIO_EN,
			
			// output to memory
			output logic[15:0] MAR_OUT,
			output logic[15:0] Data_from_CPU,

			
			// output to CPU
			output logic         BEN,
			output logic[15:0]    IR,
			output logic[15:0]    PC,
			output logic[11:0]	 LED
);


	//------------------------------------
	//				      						--
	//			Internal connections			--
	//				      						--
	//------------------------------------
	logic[15:0] MAR_IN, MDR_IN, MDR_OUT, IR_IN, IR_OUT, PC_IN, PC_OUT, REG_FILE_IN, SR1_OUT, SR2_OUT, ADDR2_MUX_OUT, ADDR1_MUX_OUT, SR2MUX_OUT; // inputs and outputs with 16-bits
	logic[2:0] SR1_val, DR_val; // indices of registers
	logic[15:0] ALU_OUT, ADDER_OUT;
	logic[15:0] IR_EXT_5, IR_EXT_6, IR_EXT_9, IR_EXT_11; // the inputs of ADDR2MUX

	assign PC = PC_OUT;
	assign IR = IR_OUT;


	//------------------------------------
	//				      						--
	//					Data Bus					--
	//				      						--
	//------------------------------------
	logic[15:0] data_bus;
	
	always_comb
	begin
		// put bits onto bus
		if(GatePC)
			data_bus = PC_OUT;
		else if(GateMDR)
			data_bus = MDR_OUT;
		else if(GateALU)
			data_bus = ALU_OUT;
		else if(GateMARMUX)
			data_bus = ADDER_OUT;
		else 
			data_bus = 16'b0;
		
		// take bits from bus
		MAR_IN = data_bus;
		IR_IN = data_bus;
		REG_FILE_IN= data_bus;
		
	end
//		NZP_LOGIC_INPUT = data_bus;
//		PC_MUX_IN_1 = data_bus;
//		MIO
	always_ff @ (posedge Clk or negedge Reset)
		begin
			if (~Reset)				// clear on reset
				LED <= 16'h0;
			else if (LD_LED)		// load the data if LD is high
				LED <= IR[11:0];
		end

	//------------------------------------
	//				      					--
	//		Reg File and ALU Block			--
	//				      					--
	//------------------------------------
	/* create registers file here */
	REG_FILE reg_file	(.Clk(Clk), .LD(LD_REG), .Reset(Reset), .SR1(SR1_val), .SR2(SR2), .DR(DR_val), .IN(REG_FILE_IN), .SR1_OUT(SR1_OUT), .SR2_OUT(SR2_OUT));
	
	/* SR1MUX and DRMUX */
	MUX_2_to_1_bit_3 SR1_MUX(.IN0(IR[11:9]), .IN1(IR[8:6]), .Select(SR1MUX), .OUT(SR1_val));
	MUX_2_to_1_bit_3 DR_MUX (.IN0(IR[11:9]), .IN1(3'b111), .Select(DRMUX), .OUT(DR_val));

	/* connecting SR2MUX with inputs from IR and REG FILE*/
	SEXT_5 	IR_EXTER_5 (.IN(IR[4:0]), .OUT(IR_EXT_5));
	MUX_2_to_1_bit_16 SR2_MUX(.IN0(SR2_OUT), .IN1(IR_EXT_5), .Select(SR2MUX), .OUT(SR2MUX_OUT));

	/* connecting ALU with inputs from SR2MUX and REG_FILE */
	ALU alu(.A(SR1_OUT), .B(SR2MUX_OUT), .ALUK(ALUK), .OUT(ALU_OUT));

	//------------------------------------
	//				      					--
	//				Bench Block				--
	//				      					--
	//------------------------------------
	BENCH 	bench	(.Clk(Clk), .Reset(Reset), .LD_BEN(LD_BEN), .LD_CC(LD_CC), .IR_11_10_9(IR_OUT[11:9]), .IN(data_bus), .BEN(BEN));


	//------------------------------------
	//				      						--
	//					PC BLOCK				--
	//				      						--
	//------------------------------------
	MUX_4_to_1_bit_16 PC_MUX (.IN1(data_bus), .IN2(ADDER_OUT), .IN0(PC_OUT+16'b1), .IN3(16'b0), .Select(PCMUX), .OUT(PC_IN));
	register_16 PC_reg (.Clk(Clk), .LD(LD_PC), .Reset(Reset), .IN(PC_IN), .data_out(PC_OUT));
	
	//------------------------------------
	//				      						--
	//					MEMORY BLOCK			--
	//				      						--
	//------------------------------------
	register_16 MAR_reg (.Clk(Clk), .LD(LD_MAR), .Reset(Reset), .IN(MAR_IN), .data_out(MAR_OUT));
	MUX_2_to_1_bit_16 MDR_MUX (.IN0(data_bus), .IN1(Data_to_CPU), .Select(MIO_EN), .OUT(MDR_IN));
	register_16 MDR_reg (.Clk(Clk), .LD(LD_MDR), .Reset(Reset), .IN(MDR_IN), .data_out(MDR_OUT));
	assign Data_from_CPU = MDR_OUT;

	//------------------------------------
	//				      						--
	//					IR BLOCK				--
	//				      						--
	//------------------------------------
	register_16 IR_reg (.Clk(Clk), .LD(LD_IR), .Reset(Reset), .IN(IR_IN), .data_out(IR_OUT));
	

	//------------------------------------
	//				      						--
	//					ADDR BLOCK				--
	//				      						--
	//------------------------------------

	/* connecting ADDR2MUX with inputs from IR */
	MUX_4_to_1_bit_16 ADDR2_MUX(.IN0(16'b0), .IN1(IR_EXT_6), .IN2(IR_EXT_9), .IN3(IR_EXT_11), .Select(ADDR2MUX), .OUT(ADDR2_MUX_OUT));
	SEXT_11  IR_EXTER_11(.IN(IR[10:0]), .OUT(IR_EXT_11));
	SEXT_9 	IR_EXTER_9 (.IN(IR[8:0]), .OUT(IR_EXT_9));
	SEXT_6 	IR_EXTER_6 (.IN(IR[5:0]), .OUT(IR_EXT_6));

	/* connecting ADDR1MUX with inputs from old PC and REG FILE */
	MUX_2_to_1_bit_16 ADDR1_MUX(.IN0(PC_OUT), .IN1(SR1_OUT), .Select(ADDR1MUX), .OUT(ADDR1_MUX_OUT));

	/* connecting ADDER with inputs from ADDR1MUX and ADDR2MUX */
	assign ADDER_OUT = ADDR1_MUX_OUT + ADDR2_MUX_OUT; // here, we simply used ADD operation for convenience.




endmodule


