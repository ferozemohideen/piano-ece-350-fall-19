module target_selector(pc_plus_one_plus_n, t, rdval, select, out);
	input [31:0] pc_plus_one_plus_n, t, rdval;
	input [1:0] select;
	output [31:0] out;
	
	wire [31:0] top, bottom;
	assign top = select[0] ? t : pc_plus_one_plus_n;
	assign bottom = select[0] ? 32'b0 : rdval;
	assign out = select[1] ? bottom : top;
	
	// 00 = input 1
	// 01 = input 2
	// 10 = input 3
	
endmodule
