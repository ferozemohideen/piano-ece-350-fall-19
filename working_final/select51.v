module select51(in1, in2, in3, in4, in5, select, out);
	input [31:0] in1, in2, in3, in4, in5;
	input [2:0] select;
	// in1 == 1
	// in2 == 2
	// in3 == 3
	// in4 == 4
	// in5 == 5
	
	output [31:0] out;
	
	assign out = select[2] ? (select[0] ? 31'b0 : in5) : (select[1] ? (select[0] ? in4 : in3) : (select[0] ? in2 : in1)); 
	
endmodule 