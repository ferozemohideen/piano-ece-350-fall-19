module register3(clk, in_enable, in, q, reset);
	input clk, in_enable, reset;
	input [2:0] in;
	output [2:0] q;
	
	genvar c;
	generate
		for (c=0; c < 3; c = c + 1) begin: dff
			dflipflop d(in[c], clk, reset, in_enable, q[c]);
		end
	endgenerate
	
endmodule