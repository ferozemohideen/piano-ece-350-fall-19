module regfile(
	clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA,
	data_readRegB, key_currently_pressed, register_eight_output);
	
	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;
	output [31:0] data_readRegA, data_readRegB;
	
	input [31:0] key_currently_pressed;
	output [31:0] register_eight_output;

	reg[31:0] registers[31:0];
	
	always @(posedge clock or posedge ctrl_reset)
	begin
		if(ctrl_reset)
			begin
				integer i;
				for(i = 0; i < 32; i = i + 1)
					begin
						registers[i] = 32'd0;
					end
			end
		else
			if(ctrl_writeEnable && ctrl_writeReg != 5'd0)
				registers[ctrl_writeReg] = data_writeReg;
			registers[5'd1] = key_currently_pressed; //Hardcode register 1 to always have the value of which key is pressed
	end
	
	assign data_readRegA = ctrl_writeEnable && (ctrl_writeReg == ctrl_readRegA) ? 32'bz : registers[ctrl_readRegA];
	assign data_readRegB = ctrl_writeEnable && (ctrl_writeReg == ctrl_readRegB) ? 32'bz : registers[ctrl_readRegB];
	
	assign register_eight_output = registers[5'd8];

	
	
endmodule