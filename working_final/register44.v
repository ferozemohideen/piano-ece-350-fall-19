module register44(clk, in_enable, in, q, reset);
	input clk, in_enable, reset;
	input [43:0] in;
	output [43:0] q;
	
	genvar c;
	generate
		for (c=0; c < 44; c = c + 1) begin: dff
			dflipflop d(in[c], clk, reset, in_enable, q[c]);
		end
	endgenerate
	
endmodule