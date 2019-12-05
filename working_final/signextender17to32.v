module signextender17to32(in, out);
	input [16:0] in;
	output [31:0] out;
	
	assign out[16:0] = in;
	
	genvar c;
	generate
		for (c = 17; c < 32; c = c + 1) begin: loop
			assign out[c] = in[16];
		end
	endgenerate
	
endmodule
		
	