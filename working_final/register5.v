module register5(clk, in_enable, in, q, reset);
	input clk, in_enable, reset;
	input [4:0] in;
	output [4:0] q;
	
	genvar c;
	generate
		for (c=0; c < 5; c = c + 1) begin: dff
			dflipflop d(in[c], clk, reset, in_enable, q[c]);
		end
	endgenerate
	
endmodule