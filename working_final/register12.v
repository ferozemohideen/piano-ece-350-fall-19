module register12(clk, in_enable, in, q, reset);
	input clk, in_enable, reset;
	input [11:0] in;
	output [11:0] q;
	
	dflipflop r0(in[0], clk, reset, in_enable, q[0]);
	dflipflop r1(in[1], clk, reset, in_enable, q[1]);
	dflipflop r2(in[2], clk, reset, in_enable, q[2]);
	dflipflop r3(in[3], clk, reset, in_enable, q[3]);
	dflipflop r4(in[4], clk, reset, in_enable, q[4]);
	dflipflop r5(in[5], clk, reset, in_enable, q[5]);
	dflipflop r6(in[6], clk, reset, in_enable, q[6]);
	dflipflop r7(in[7], clk, reset, in_enable, q[7]);
	dflipflop r8(in[8], clk, reset, in_enable, q[8]);
	dflipflop r9(in[9], clk, reset, in_enable, q[9]);
	dflipflop r10(in[10], clk, reset, in_enable, q[10]);
	dflipflop r11(in[11], clk, reset, in_enable, q[11]);
	
endmodule