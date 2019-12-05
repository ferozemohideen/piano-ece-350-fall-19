module register171(clk, in_enable, in, q, reset);
	input clk, in_enable, reset;
	input [170:0] in;
	output [170:0] q;
	
	genvar c;
	generate
		for (c=0; c < 171; c = c + 1) begin: dff
			dflipflop d(in[c], clk, reset, in_enable, q[c]);
		end
	endgenerate
	
endmodule