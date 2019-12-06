module music(counter, out);
	input [31:0] counter;
	output reg out;
	always @(counter) begin
		if (counter == 32'd0)
			out = 7'b1;
		else if (counter == 32'd500000000)
			out = 7'b0;
	end
endmodule
		