

module lab5_toplevel
(
	input 	logic[7:0]	S,
	input 	logic 		Clk, Reset, Run, ClearA_LoadB,
	output	logic[6:0]	AhexU, AhexL, BhexU, BhexL,
	output	logic[7:0]	Aval, Bval,
	output	logic			X
 	
);

	 //local logic variables go here
//	 logic Reset_SH, LoadA_SH, LoadB_SH, Execute_SH;
//	 logic Ld_A, Ld_B, newA, newB, opA, opB, bitA, bitB, Shift_En, F_A_B;
//	 logic [7:0] A, B, Din_S;
		logic[7:0] A, B;
		logic XO;	// output of X
		logic XI;	// input of X for next state
		logic SUB, ADD;
		logic LoadXA, ResetXA;
		logic shift;
		logic AO;
		logic fn;
		logic[8:0] ADDER_OUT;
		logic CLR_XA_LD_B;
		logic NotReset;
		logic NotRun;
		logic NotClearA_LoadB;
		logic CLR_XA;
	 
	 
	 //We can use the "assign" statement to do simple combinational logic
	 assign LoadXA = SUB ^ ADD;
	 assign ResetXA = NotReset | CLR_XA_LD_B | CLR_XA;
	 assign fn = SUB;
	 assign XI = ADDER_OUT[8];
	 assign NotReset = ~Reset;
	 assign NotRun = ~Run;
	 assign NotClearA_LoadB = ~ClearA_LoadB;
	 
	 
	 //output
	 assign X = XO;
	 assign Aval = A;
	 assign Bval = B;
	
//		input Clk, Load, Reset, D, 
//		output logic Q 
	Dreg DregX (.Clk(Clk), .Load(LoadXA), .Reset(ResetXA), .D(XI), .Q(XO) );

//		input  logic Clk, Reset, Shift_In, Load, Shift_En,
//    input  logic [7:0]  D,
//    output logic Shift_Out,
//    output logic [7:0]  Data_Out);
	 reg_8 RegA(.Clk(Clk), .Reset(ResetXA), .Shift_In(XO), .Load(LoadXA), .Shift_En(shift), .D(ADDER_OUT[7:0]), .Shift_Out(AO), .Data_Out(A));
	 reg_8 RegB(.Clk(Clk), .Reset(NotReset), .Shift_In(AO), .Load(CLR_XA_LD_B), .Shift_En(shift), .D(S), .Shift_Out(), .Data_Out(B));
	 
//    input   	logic[7:0]     A, B,
//	 	input 	logic				fn, 
//    output  	logic[8:0]     S
	 ADD_SUB9 adder(.A(A), .B(S), .fn(fn), .S(ADDER_OUT));
	 
//		input logic CLR_LDB,
//		input	logic Run,
//		input logic Reset,
//		input logic M,
//		input logic Clk
//		output logic CLR_XA_LD_B,
//		output logic Shift_XAB, 
//		output logic ADD,	// ADD = 1 for add op
//		output logic SUB, // SUB = 1 for sub op 

control control
( 	.CLR_LDB(NotClearA_LoadB),
	.Run(NotRun),
	.Reset(NotReset),
	.M(B[0]),
	.Clk(Clk),
	.CLR_XA_LD_B(CLR_XA_LD_B),
	.Shift_XAB(shift), 
	.ADD(ADD),	
	.SUB(SUB),
	.CLR_XA(CLR_XA)
);



	 HexDriver        HexAL (
                        .In0(A[3:0]),
                        .Out0(AhexL) );
	 HexDriver        HexBL (
                        .In0(B[3:0]),
                        .Out0(BhexL) );
								
	 //When you extend to 8-bits, you will need more HEX drivers to view upper nibble of registers, for now set to 0
	 HexDriver        HexAU (
                        .In0(A[7:4]),
                        .Out0(AhexU) );	
	 HexDriver        HexBU (
                       .In0(B[7:4]),
                        .Out0(BhexU) );


endmodule