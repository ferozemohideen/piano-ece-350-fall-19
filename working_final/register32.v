module register32(clk, in_enable, in, q, reset);
	input clk, in_enable, reset;
	input [31:0] in;
	output [31:0] q;
	
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
	dflipflop r12(in[12], clk, reset, in_enable, q[12]);
	dflipflop r13(in[13], clk, reset, in_enable, q[13]);
	dflipflop r14(in[14], clk, reset, in_enable, q[14]);
	dflipflop r15(in[15], clk, reset, in_enable, q[15]);
	dflipflop r16(in[16], clk, reset, in_enable, q[16]);
	dflipflop r17(in[17], clk, reset, in_enable, q[17]);
	dflipflop r18(in[18], clk, reset, in_enable, q[18]);
	dflipflop r19(in[19], clk, reset, in_enable, q[19]);
	dflipflop r20(in[20], clk, reset, in_enable, q[20]);
	dflipflop r21(in[21], clk, reset, in_enable, q[21]);
	dflipflop r22(in[22], clk, reset, in_enable, q[22]);
	dflipflop r23(in[23], clk, reset, in_enable, q[23]);
	dflipflop r24(in[24], clk, reset, in_enable, q[24]);
	dflipflop r25(in[25], clk, reset, in_enable, q[25]);
	dflipflop r26(in[26], clk, reset, in_enable, q[26]);
	dflipflop r27(in[27], clk, reset, in_enable, q[27]);
	dflipflop r28(in[28], clk, reset, in_enable, q[28]);
	dflipflop r29(in[29], clk, reset, in_enable, q[29]);
	dflipflop r30(in[30], clk, reset, in_enable, q[30]);
	dflipflop r31(in[31], clk, reset, in_enable, q[31]);
	
	
	
endmodule