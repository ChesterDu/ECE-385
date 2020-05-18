
// Module with logic for BEN
module BENCH (input  logic Clk, Reset,
				  input	logic LD_BEN, LD_CC,
				  input 	logic[2:0] IR_11_10_9,
				  input	logic[15:0] IN,
				  output	logic BEN	);

    logic N_IN, Z_IN, P_IN; // inputs to N, Z, P registers
    logic N_OUT, Z_OUT, P_OUT; // outputs to N, Z, P registers
    logic BEN_IN; // input to the FF of BEN

        /* logic from data path to NZP FFs */
        always_comb
        begin
            /* negative */
            if(IN[15] == 1)
            begin
                N_IN = 1'b1;
                Z_IN = 1'b0;
                P_IN = 1'b0;
            end
            else
				begin
            /* zero */
            if(IN == 16'b0)
            begin
                N_IN = 1'b0;
                Z_IN = 1'b1;
                P_IN = 1'b0;
            end
            else
            /* positive */
            begin
                N_IN = 1'b0;
                Z_IN = 1'b0;
                P_IN = 1'b1;
            end
				end
        end	  

        /* 3 flip-flops to store N, Z, P */
        always_ff @ (posedge Clk or negedge Reset)
			begin
				if (~Reset)				// clear on reset
					begin
					N_OUT <= 1'b0;
                    Z_OUT <= 1'b0;
                    P_OUT <= 1'b0;
					end
				else if (LD_CC)		// load the data if LD is high
					begin
					N_OUT <= N_IN;
                    Z_OUT <= Z_IN;
                    P_OUT <= P_IN;
					end
			end


        /* logic from NZP to BEN */
        assign BEN_IN = (IR_11_10_9[2] & N_OUT) + (IR_11_10_9[1] & Z_OUT) + (IR_11_10_9[0] & P_OUT);
        

        /* flip-flops to store BEN */
        always_ff @ (posedge Clk or negedge Reset)
			begin
				if (~Reset)				// clear on reset
					BEN <= 1'b0;
				else if (LD_BEN)		// load the data if LD is high
					BEN <= BEN_IN;
			end
        
				  
endmodule