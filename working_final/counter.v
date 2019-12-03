module counter(clk, numcyc, out);



	input clk;

	input [31:0] numcyc;

	output reg [31:0] out;

	reg [31:0] cnt;



	initial begin



	out <= 32'd100000000;

	end



	always @(posedge clk)

	begin

		cnt <= cnt + 1;

		if (numcyc < cnt)

			begin

			cnt <= 32'b0;

			out <= -out; 

			end



	end

endmodule