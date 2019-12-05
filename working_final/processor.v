/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB,                   // I: Data from port B of regfile
//	 out_of_if_id,
//	 out_of_ex_mem,
//	 regWrite,
//	 aluInputAController,
//	 aluInputBController
);
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;

    /* YOUR CODE STARTS HERE */
	 
	 // PROGRAM COUNTER
	 wire [31:0] into_PC, out_of_PC, PC_plus_1;
	 register32 PC(clock, ~stall, into_PC, out_of_PC, reset);
	 alu addPC(.data_operandA(32'b1), .data_operandB(out_of_PC), .ctrl_ALUopcode(5'b0), 
			.data_result(PC_plus_1));
			
	// ADD A MUX FOR into_PC
	 assign into_PC = (out_of_ex_mem[4] | valid_blt | valid_bne | valid_betx) ? next_pc_target : PC_plus_1;
	 
	 wire flush;
	 assign flush = (out_of_ex_mem[4] | valid_blt | valid_bne | valid_betx);
	 
	 // IMEM
	 assign address_imem = out_of_PC[11:0];
		
	 // IF_ID REGISTER
	 // this register holds the instruction (32 bits) and the incremented PC (32 bits) (64 bits total)
	 // top bits - incremented pc, bottom bits - instruction
	 wire [63:0] into_if_id;
	 wire [63:0] out_of_if_id;
	 assign into_if_id[63:32] = PC_plus_1;
	 assign into_if_id[31:0] = q_imem;
	 register64 IF_ID(clock, ~stall, into_if_id, out_of_if_id, (reset | flush));
	 
	 wire [31:0] instruction;
	 assign instruction = out_of_if_id[31:0];
	 
	 // PARSE INSTRUCTION FOR VALUES
	 wire [4:0] opcode;
	 assign opcode = instruction[31:27];
	 
	 wire [4:0] rd;
	 assign rd = instruction[26:22];
	 
	 wire [4:0] rs;
	 assign rs = instruction[21:17];
	 
	 wire [4:0] rt;
	 assign rt = instruction[16:12];
	 
	 wire [4:0] shamt;
	 assign shamt = instruction[11:7];
	 
	 wire [4:0] aluop;
	 assign aluop = instruction[6:2];
	 
	 wire [16:0] N;
	 assign N = instruction[16:0];
	 
	 wire [26:0] T;
	 assign T = instruction[26:0];
	 
	 // DECODE CONTROL SIGNALS
	 wire a, b, c, d, e;
	 assign a = opcode[4];
	 assign b = opcode[3];
	 assign c = opcode[2];
	 assign d = opcode[1];
	 assign e = opcode[0];
	 
	 wire f, g, h, i, j;
	 assign f = aluop[4];
	 assign g = aluop[3];
	 assign h = aluop[2];
	 assign i = aluop[1];
	 assign j = aluop[0];
	 
	 wire first_read_register;
	 assign first_read_register = a & ~b & c & d & ~e;
	 
	 wire second_read_register;
	 assign second_read_register = (~a & ~b & c & d & e) | (~a & ~b & ~c & d & ~e) | (~a & ~b & c & ~d & ~e) | (~a & ~b & c & d & ~e);
	 
	 wire regWrite;
	 assign regWrite = (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & ~i & ~j) 
		| (~a & ~b & c & ~d & e)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & ~i & j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & i & ~j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & i & j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & ~i & ~j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & ~i & j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & ~j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & j)
		| (~a & b & ~c & ~d & ~e)
		| (~a & ~b & ~c & d & e)
		| (a & ~b & c & ~d & e);

		
	 wire aluSRC;
	 assign aluSRC = (~a & ~b & c & ~d & e) | (~a & ~b & c & d & e) | (~a & b & ~c & ~d & ~e);
	 
	 wire [2:0] alu_select;
	 assign alu_select[2] = (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & ~i & ~j) 
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & ~i & j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & ~j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & j);
		
	 assign alu_select[1] = (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & i & ~j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & i & j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & ~j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & j);
		
	 assign alu_select[0] = (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & ~i & j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & i & j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & ~i & j)
		| (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & j);
		
	 wire [1:0] nextPC;
	 assign nextPC[1] = (~a & ~b & c & ~d & ~e);
	 assign nextPC[0] = (~a & ~b & ~c & ~d & e) | (~a & ~b & ~c & d & e) | (a & ~b & c & d & ~e);
	 
	 wire jump;
	 assign jump = (~a & ~b & ~c & ~d & e) | (~a & ~b & ~c & d & e) | (~a & ~b & c & ~d & ~e);
	 
	 wire bne;
	 assign bne = (~a & ~b & ~c & d & ~e);
	 
	 wire blt;
	 assign blt = (~a & ~b & c & d & ~e);
	 
	 wire bex;
	 assign bex = (a & ~b & c & d & ~e);
		
	 wire memWrite;
	 assign memWrite = (~a & ~b & c & d & e);
	 
	 wire memToReg;
	 assign memToReg = (~a & b & ~c & ~d & ~e);	 
	 
	 wire jal;
	 assign jal = (~a & ~b & ~c & d & e);
	 
	 wire setx;
	 assign setx = (a & ~b & c & ~d & e);
	 
	 wire [2:0] setRstatus;
	 assign setRstatus[2] = (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & j);
	 assign setRstatus[1] = (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & ~j) | (~a & ~b & ~c & ~d & ~e & ~f & ~g & ~h & ~i & j);
	 assign setRstatus[0] = (~a & ~b & ~c & ~d & ~e & ~f & ~g & h & i & ~j) | (~a & ~b & c & ~d & e);

	 
////////////// DECODE STAGE ////////////////////////////////////////////////////////////////
	 
	 // decide first register (rs)
	 wire [4:0] dont_stall_rs;
	 assign dont_stall_rs = first_read_register ? 5'd30 : rs;
	 assign ctrl_readRegA = stall ? 5'b0 : dont_stall_rs;
	 
	 // decide second register (rt)
	 wire [4:0] dont_stall_rt;
	 assign dont_stall_rt = second_read_register ? rd : rt;
	 assign ctrl_readRegB = stall ? 5'b0 : dont_stall_rt;
	 
	 // decide real rd (RD)
	 wire [4:0] temprd;
	 assign temprd = jal ? 5'd31 : rd;
	 
	 wire [4:0] RD;
	 assign RD = setx ? 5'd30 : temprd;
	 
	 // POPULATE ID/EX REGISTER
	 // 176 [PC+1, dataA, dataB, SEI, RD, T, alu_select, shamt, regWrite, aluSRC, nextPC, jump_or_branch, memWrite, memToReg, jal, setx] 0
	 wire [176:0] into_id_ex;
	 assign into_id_ex[176:145] = out_of_if_id[63:32];
	 assign into_id_ex[144:113] = data_readRegA;
	 assign into_id_ex[112:81] = data_readRegB;
	 signextender17to32 extend(N, into_id_ex[80:49]);
	 assign into_id_ex[48:44] = RD;
	 assign into_id_ex[43:17] = T;
	 assign into_id_ex[16:14] = alu_select;
	 assign into_id_ex[13:9] = shamt;
	 assign into_id_ex[8] = regWrite;
	 assign into_id_ex[7] = aluSRC;
	 assign into_id_ex[6:5] = nextPC;
	 assign into_id_ex[4] = jump;
	 assign into_id_ex[3] = memWrite;
	 assign into_id_ex[2] = memToReg;
	 assign into_id_ex[1] = jal;
	 assign into_id_ex[0] = setx;
	 
	 // branch registers that I forgot about
	 wire[2:0] into_id_ex_branch;
	 assign into_id_ex_branch[2] = bne;
	 assign into_id_ex_branch[1] = blt;
	 assign into_id_ex_branch[0] = bex;
	 
	 // stalling branch register
	 wire [2:0] into_id_ex_branch_final;
	 assign into_id_ex_branch_final = stall ? 3'b0 : into_id_ex_branch;
	 
	 // holds bne, blt, bex signals
	 wire [2:0] out_of_id_ex_branch;
	 register3 ID_EX_BRANCH(clock, 1'b1, into_id_ex_branch_final, out_of_id_ex_branch, (reset | flush));
	 
	 // stall big register
	 wire [176:0] into_id_ex_final;
	 assign into_id_ex_final = stall ? 177'b0 : into_id_ex;
	 
	 // holds most signals
	 wire [176:0] out_of_id_ex;
	 register177 ID_EX(clock, 1'b1, into_id_ex_final, out_of_id_ex, (reset | flush));
	 
	 // holds rs and rt - already stalled if necessary
	 wire [4:0] out_of_id_ex_rs, out_of_id_ex_rt;
	 register5 ID_EX_RS(clock, 1'b1, ctrl_readRegA, out_of_id_ex_rs, (reset | flush));
	 register5 ID_EX_RT(clock, 1'b1, ctrl_readRegB, out_of_id_ex_rt, (reset | flush));
	 
	 // stall rstatus register
	 wire [2:0] setRstatus_final;
	 assign setRstatus_final = stall ? 3'b0 : setRstatus;
	 
	 // holds selectRstatus
	 wire [2:0] out_of_id_ex_set_rstatus;
	 register3 ID_EX_SET_RSTATUS(clock, 1'b1, setRstatus_final, out_of_id_ex_set_rstatus, (reset | flush));
	 

////////////// EXECUTE STAGE ////////////////////////////////////////////////////////////////
	 // create bus to put all values
	 // 170 [PC+1+N, RESULT, dataB, RD, T, dataA != dataB, dataA > dataB, dataA != 0, regWrite, PC+1, nextPC, jump_or_branch, memWrite, memToReg, jal, setx] 0
	 wire [170:0] into_ex_mem;
	 
	 // get PC + 1 + N
	 alu secondaryALU(
		.data_operandA(out_of_id_ex[176:145]),			// PC + 1
		.data_operandB(out_of_id_ex[80:49]), 			// sign extended immediate
		.ctrl_ALUopcode(5'b0),								// add
		.data_result(into_ex_mem[170:139])				// pc + 1 + n
	 );				
	 
	 // main ALU
	 wire [31:0] secondALUinput;
	 assign secondALUinput = out_of_id_ex[7] ? out_of_id_ex[80:49] : tempIntoAluB; // aluSRC ? SEI : (dataB or bypassed from mem/wb or bp from ex/mem)
	 
	 wire isLessThan, isGreaterThan, isNotEqual, overflow;
	 wire [31:0] main_alu_result;
	 alu mainALU(
		intoAluA, 						// dataA or bypassed from mem/wb or bypassed from ex/mem
		secondALUinput, 				// dataB or sign extended immediate
		out_of_id_ex[16:14], 		// alu_select
		out_of_id_ex[13:9], 			// shamt
		main_alu_result,				// RESULT
		isNotEqual, 					// is not equal
		isLessThan,						// is less than
		overflow
	 );
	 
	 // overflow decides if rstatus changes to something else, either 1, 2, 3, 4, or 5
	 wire [31:0] exception_value;
	 select51 set_exception_value(32'd1, 32'd2, 32'd3, 32'd4, 32'd5, out_of_id_ex_set_rstatus, exception_value);
	 
	 assign into_ex_mem[138:107] = overflow ? exception_value : main_alu_result;
	 
	 wire [4:0] exception_register_or_normal;
	 assign exception_register_or_normal = overflow ? 5'd30 : out_of_id_ex[48:44];	 
	 
	 assign isGreaterThan = ~isLessThan & isNotEqual;
	 
	 // for sw or jr we treat rd as rt, so we can do this:
	 //												dataB						out of mem/wb	out of ex/mem				rt conflict checker	into ex/mem register
	 target_selector selectDataBPropagate(out_of_id_ex[112:81], data_writeReg, out_of_ex_mem[138:107], aluInputBController, into_ex_mem[106:75]);
	 
	 assign into_ex_mem[74:70] = exception_register_or_normal; // RD
	 assign into_ex_mem[69:43] = out_of_id_ex[43:17]; // T
	 assign into_ex_mem[42] = isNotEqual; 
	 assign into_ex_mem[41] = isGreaterThan;
	 
	 // for bex we treat rstatus as rs, so we can do this:
	 wire [31:0] correctRstatus;
	 //												dataA						 out of mem/wb	 out of ex/mem				 rs conflict checker  
	 target_selector selectCorrectRstatus(out_of_id_ex[144:113], data_writeReg, out_of_ex_mem[138:107], aluInputAController, correctRstatus);
	 
	 assign into_ex_mem[40] = |correctRstatus; 
	 assign into_ex_mem[39] = out_of_id_ex[8];			// regWrite
	 assign into_ex_mem[38:7] = out_of_id_ex[176:145]; // PC + 1
	 assign into_ex_mem[6:0] = out_of_id_ex[6:0]; // rest of it
	 
	 wire [170:0] out_of_ex_mem;
	 register171 EX_MEM(clock, 1'b1, into_ex_mem, out_of_ex_mem, reset);
	 
	 wire [2:0] out_of_ex_mem_branch;
	 register3 EX_MEM_BRANCH(clock, 1'b1, out_of_id_ex_branch, out_of_ex_mem_branch, reset);
	 
	 // holds rs and rt
	 wire [4:0] out_of_ex_mem_rs, out_of_ex_mem_rt;
	 register5 EX_MEM_RS(clock, 1'b1, out_of_id_ex_rs, out_of_ex_mem_rs, reset);
	 register5 EX_MEM_RT(clock, 1'b1, out_of_id_ex_rt, out_of_ex_mem_rt, reset);
	 
	 
////////////// MEMORY STAGE ////////////////////////////////////////////////////////////////
	 // create bus to put all values
	 wire [98:0] into_mem_wb;
	 
	 assign address_dmem = out_of_ex_mem[118:107];
	 assign data = dataToDmem;
	 assign wren = out_of_ex_mem[3];
	 
	 assign into_mem_wb[98:67] = out_of_ex_mem[2] ? q_dmem : out_of_ex_mem[138:107]; // data to write to regfile
	 assign into_mem_wb[66:62] = out_of_ex_mem[74:70]; // RD
	 assign into_mem_wb[61] = out_of_ex_mem[39]; // regWrite
	 assign into_mem_wb[60:34] = out_of_ex_mem[69:43]; //T
	 assign into_mem_wb[33:2] = out_of_ex_mem[38:7]; // PC + 1
	 assign into_mem_wb[1:0] = out_of_ex_mem[1:0]; // jal and setx
	 
	 // handle PC branching
	 wire [31:0] next_pc_target;
	 assign next_pc_target[31:27] = 5'b0;
	 
	 // pick next pc target
	 target_selector selectnextpctarget(
		.pc_plus_one_plus_n(out_of_ex_mem[165:139]), 	// PC + 1 + N
		.t(out_of_ex_mem[69:43]),								// T
		.rdval(out_of_ex_mem[101:75]),						// dataB
		.select(out_of_ex_mem[6:5]),							// nextPC
		.out(next_pc_target[26:0])								// next_pc_target
	 );
	 
	 wire valid_bne, valid_blt, valid_betx;
	 assign valid_bne = out_of_ex_mem[42] & out_of_ex_mem_branch[2]; // is not equal and bne
	 assign valid_blt = out_of_ex_mem[41] & out_of_ex_mem_branch[1]; // rs > rd and blt
	 assign valid_betx = out_of_ex_mem[40] & out_of_ex_mem_branch[0]; // rstatus != 0 and betx
	 
	 wire [98:0] out_of_mem_wb;
	 register99 MEM_WB(clock, 1'b1, into_mem_wb, out_of_mem_wb, reset);
	 
	 // store if the last instruction was a load
	 wire out_of_mem_wb_load;
	 register last_load_instruction(clock, 1'b1, out_of_ex_mem[2], out_of_mem_wb_load, reset);
	 
////////////// WRITEBACK STAGE ////////////////////////////////////////////////////////////////
	 wire [31:0] normal_data_or_T;
	 wire [31:0] full_t;
	 assign full_t[31:27] = 5'b0;
	 assign full_t[26:0] = out_of_mem_wb[60:34];
	 
	 assign normal_data_or_T = out_of_mem_wb[0] ? full_t : out_of_mem_wb[98:67]; // setx ? T : data_to_write
	 
	 assign data_writeReg = out_of_mem_wb[1] ? out_of_mem_wb[33:2] : normal_data_or_T; // jal ? PC + 1 : data_to_write
	 assign ctrl_writeReg = out_of_mem_wb[66:62]; // rd
	 assign ctrl_writeEnable = out_of_mem_wb[61]; // regWrite
	 
////////////// FORWARDING / BYPASSING ////////////////////////////////////////////////////////////////
	 // mem/wb --> id/ex
	 // if mem/wb regWrite 
	 // AND mem/wb RD != 0 
	 // AND not(ex/mem bypassing: ex/mem regWrite AND ex/mem RD != 0 AND ex/mem RD == id/ex rs) 
	 // AND mem/wb.rd == id/ex.rs, THEN
	 // forward mem/wb to dataA --> code for mux is 01
	 wire [1:0] aluInputAController;
	 assign aluInputAController[0] = 
		ctrl_writeEnable &
		(|(out_of_mem_wb[66:62])) &
		~(out_of_ex_mem[39] & (|(out_of_ex_mem[74:70])) & (&(out_of_ex_mem[74:70] ~^ out_of_id_ex_rs))) & 
		(&(out_of_mem_wb[66:62] ^~ out_of_id_ex_rs));
		
	 wire [1:0] aluInputBController;
	 assign aluInputBController[0] = 
		ctrl_writeEnable &
		(|(out_of_mem_wb[66:62])) &
		~(out_of_ex_mem[39] & (|(out_of_ex_mem[74:70])) & (&(out_of_ex_mem[74:70] ~^ out_of_id_ex_rt))) & 
		(&(out_of_mem_wb[66:62] ^~ out_of_id_ex_rt));
		
	 // ex/mem --> id/ex
	 // if ex/mem regwrite
	 // AND ex/mem RD != 0
	 // AND ex/mem RD == id/ex rs, THEN
	 // forward ex/mem to dataA --> code for mux is 10
	 assign aluInputAController[1] = 
		out_of_ex_mem[39] &
		(|(out_of_ex_mem[74:70])) &
		(&(out_of_ex_mem[74:70] ~^ out_of_id_ex_rs));
		
	 assign aluInputBController[1] = 
		out_of_ex_mem[39] &
		(|(out_of_ex_mem[74:70])) &
		(&(out_of_ex_mem[74:70] ~^ out_of_id_ex_rt));
		
	 wire [31:0] intoAluA;
	 target_selector selectAluA(out_of_id_ex[144:113], data_writeReg, out_of_ex_mem[138:107], aluInputAController, intoAluA);
	 
	 wire [31:0] tempIntoAluB;
	 target_selector selectAluB(out_of_id_ex[112:81], data_writeReg, out_of_ex_mem[138:107], aluInputBController, tempIntoAluB);
	 
	 // mem/wb --> id/ex but for the dataB for a sw / jr ($rd)
	 // if mem/wb regwrite
	 // AND mem/wb RD != 0
	 // AND not(ex/mem bypassing: ex/mem regwrite AND ex/mem != 0 AND ex/mem rd = id/ex
	 
	 // ex/mem --> id/ex but for the dataB for a sw / jr ($rd)
	 
	 
	 // mem/wb --> id/ex but for the dataA for a bex ($rstatus)
	 
	 
	 // ex/mem --> id/ex but for the dataA for a bex ($rstatus)
	 // THESE CASES ARE HANDLED WITH NORMAL BYPASSING^^
	 
	 // mem/wb --> ex/mem used for lw followed by sw
	 // if mem/wb load
	 // AND ex/mem memWrite
	 // AND ex/mem rt == mem/wb rd
	 // AND mem/wb rd != 0
	 wire selectDataToDmem;
	 assign selectDataToDmem = 
		out_of_mem_wb_load &
		out_of_ex_mem[3] &
	   (|(out_of_mem_wb[66:62])) &
		(&(out_of_ex_mem_rt ~^ ctrl_writeReg));
	 
	 wire [31:0] dataToDmem;
	 assign dataToDmem = selectDataToDmem ? data_writeReg : out_of_ex_mem[106:75];
	 
	 // data hazard / stall
	 // if id/ex memToReg
	 // AND (((id/ex RD == if/id rt) AND ~if/id memWrite) OR (id/ex RD == if/id rs))
	 // THEN stall
	 wire stall;
	 assign stall = 
		out_of_id_ex[2] & 
		(((&(out_of_id_ex[48:44] ~^ dont_stall_rt)) & ~memWrite) | (&(out_of_id_ex[48:44] ~^ dont_stall_rs)));
		


endmodule
