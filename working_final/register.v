module register(clk, in_enable, in, q, reset);
	input clk, in_enable, reset;
	input in;
	output q;
	
	genvar c;
	generate
		for (c=0; c < 1; c = c + 1) begin: dff
			dflipflop d(in, clk, reset, in_enable, q);
		end
	endgenerate
	
endmodule