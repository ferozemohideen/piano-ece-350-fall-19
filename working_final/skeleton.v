module skeleton(start, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	debug_data_in, debug_addr, leds, 						// extra debugging ports
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50,
	SW,
	
	CLOCK_27,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	I2C_SCLK,
	
	);  													// 50 MHz clock
		
	////////////////////////	VGA	////////////////////////////
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	input				CLOCK_50;
	input		[6:0]	SW;

	////////////////////////	PS2	////////////////////////////
	input 			start;
	inout 			ps2_data, ps2_clock;
	
	////////////////////////	LCD and Seven Segment	////////////////////////////
	output 			   lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_data_in;
	output   [11:0]   debug_addr;
	
	
	wire c_note, d_note, e_note, f_note, g_note, a_note, b_note;

	assign c_note = SW[6];

	assign d_note = SW[5];

	assign e_note = SW[4];

	assign f_note = SW[3];

	assign g_note = SW[2];

	assign a_note = SW[1];

	assign b_note = SW[0];
	
	
	
	wire			 clock;
	wire			 lcd_write_en;
	wire 	[31:0] lcd_write_data;
	wire	[7:0]	 ps2_key_data;
	wire			 ps2_key_pressed;
	wire	[7:0]	 ps2_out;	
	
	// clock divider (by 5, i.e., 10 MHz)
	pll div(CLOCK_50,inclock);
	assign clock = CLOCK_50;
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	//assign clock = inclock;
	
	// your processor
	processor myprocessor(clock, ~resetn, /*ps2_key_pressed, ps2_out, lcd_write_en, lcd_write_data,*/ debug_data_in, debug_addr);
	
	// keyboard controller
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	
	// lcd controller
	lcd mylcd(clock, ~resetn, 1'b1, ps2_out, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// example for sending ps2 data to the first two seven segment displays
	Hexadecimal_To_Seven_Segment hex1(ps2_out[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(ps2_out[7:4], seg2);
	
	// the other seven segment displays are currently set to 0
	Hexadecimal_To_Seven_Segment hex3(4'b0, seg3);
	Hexadecimal_To_Seven_Segment hex4(4'b0, seg4);
	Hexadecimal_To_Seven_Segment hex5(4'b0, seg5);
	Hexadecimal_To_Seven_Segment hex6(4'b0, seg6);
	Hexadecimal_To_Seven_Segment hex7(4'b0, seg7);
	Hexadecimal_To_Seven_Segment hex8(4'b0, seg8);
	
	// some LEDs that you could use for debugging if you wanted
	assign leds = 8'b00101011;
		
	// VGA
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
	vga_controller vga_ins(.iRST_n(DLY_RST),
								 .iVGA_CLK(VGA_CLK),
								 .oBLANK_n(VGA_BLANK),
								 .oHS(VGA_HS),
								 .oVS(VGA_VS),
								 .b_data(VGA_B),
								 .g_data(VGA_G),
								 .r_data(VGA_R),
								 
							 .c(c_note | play_mary[6]),

							 .d(d_note | play_mary[5]),

							 .e(e_note | play_mary[4]),

							 .f(f_note | play_mary[3]),

							 .g(g_note | play_mary[2]),

							 .a(a_note | play_mary[1]),

							 .b(b_note | play_mary[0]));
							 
	input				CLOCK_27;
	input		[3:0]	KEY;

	input				AUD_ADCDAT;

	// Bidirectionals
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;

	inout				I2C_SDAT;

	// Outputs
	output				AUD_XCK;
	output				AUD_DACDAT;

	output				I2C_SCLK;

	/*****************************************************************************
	 *                 Internal Wires and Registers Declarations                 *
	 *****************************************************************************/
	// Internal Wires
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;
	
	reg [31:0] add0, add1, add2, add3, add4, add5, add6, metVal, cnt0, cnt1, cnt2, cnt3, cnt4, cnt5, cnt6;
	
//	reg [31:0] counter;
	 initial begin
		add0 <= 32'b0;
		add1 <= 32'b0;
		add2 <= 32'b0;
		add3 <= 32'b0;
		add4 <= 32'b0;
		add5 <= 32'b0;
		add6 <= 32'b0;
		metVal <= 32'b0;
		cnt0 <= 32'b0;
		cnt1 <= 32'b0;
		cnt2 <= 32'b0;
		cnt3 <= 32'b0;
		cnt4 <= 32'b0;
		cnt5 <= 32'b0;
		cnt6 <= 32'b0;
		
//		play_c <= 1'b0;
		counter <= 8'd100;
		
	 end

	 /*****************************************************************************

	 *                         LAB 6 SOUNDS END HERE                              *

	 *****************************************************************************/
	reg [25:0] slow_clk;
	reg [7:0] counter;
	
	always @(posedge CLOCK_50) begin
		// c
		if (SW[6] | play_mary[6]) begin
			cnt0 <= cnt0+1;
			if (cnt0 >= 32'd96000) begin
				cnt0 <= 0;
				if (add0 == 32'd100000000) begin
					add0 <= -32'd100000000;
				end
				else begin
					add0 <= 32'd100000000;
				end
			end
		end else begin
			add0 <= 32'd0;
		end
		
		
		
		if (slow_clk == 26'd25000000) begin
			if (start) begin
				counter <= 0;
			end
			else if (counter == 8'd255) begin
				counter <= 8'd70;
			end
			else begin
				counter <= counter + 8'b1;
			end
        slow_clk <= 0;
		end
		 else begin
			  slow_clk <= slow_clk + 1'b1;
		 end
		
		// d
		if (SW[5] | play_mary[5]) begin
			cnt1 <= cnt1+1;
			if (cnt1 >= 32'd86000) begin
				cnt1 <= 0;
				if (add1 == 32'd100000000) begin
					add1 <= -32'd100000000;
				end
				else begin
					add1 <= 32'd100000000;
				end
			end
		end else begin
			add1 <= 32'd0;
		end
		
		// e
		if (SW[4] | play_mary[4]) begin
			cnt2 <= cnt2+1;
			if (cnt2 >= 32'd76000) begin
				cnt2 <= 0;
				if (add2 == 32'd100000000) begin
					add2 <= -32'd100000000;
				end
				else begin
					add2 <= 32'd100000000;
				end
			end
		end else begin
			add2 <= 32'd0;
		end
		
		// f
		if (SW[3] | play_mary[3]) begin
			cnt3 <= cnt3+1;
			if (cnt3 >= 32'd71500) begin
				cnt3 <= 0;
				if (add3 == 32'd100000000) begin
					add3 <= -32'd100000000;
				end
				else begin
					add3 <= 32'd100000000;
				end
			end
		end else begin
			add3 <= 32'd0;
		end
		
		// g
		if (SW[2] | play_mary[2]) begin
			cnt4 <= cnt4+1;
			if (cnt4 >= 32'd64000) begin
				cnt4 <= 0;
				if (add4 == 32'd100000000) begin
					add4 <= -32'd100000000;
				end
				else begin
					add4 <= 32'd100000000;
				end
			end
		end else begin
			add4 <= 32'd0;
		end
		
		// a
		if (SW[1] | play_mary[1]) begin
			cnt5 <= cnt5+1;
			if (cnt5 >= 32'd57000) begin
				cnt5 <= 0;
				if (add5 == 32'd100000000) begin
					add5 <= -32'd100000000;
				end
				else begin
					add5 <= 32'd100000000;
				end
			end
		end else begin
			add5 <= 32'd0;
		end
		
		// b
		if (SW[0] | play_mary[0]) begin
			cnt6 <= cnt6+1;
			if (cnt6 >= 32'd51000) begin
				cnt6 <= 0;
				if (add6 == 32'd100000000) begin
					add6 <= -32'd100000000;
				end
				else begin
					add6 <= 32'd100000000;
				end
			end
		end else begin
			add6 <= 32'd0;
		end
		
	end



	assign read_audio_in			= audio_in_available & audio_out_allowed;



	wire [31:0] left_in, right_in, left_out, right_out;

	assign left_in = left_channel_audio_in;

	assign right_in = right_channel_audio_in;

	assign left_out = metVal + add0 + add1 + add2 + add3 + add4 + add5 + add6;

	assign right_out = metVal + add0 + add1 + add2 + add3 + add4 + add5 + add6;


	assign left_channel_audio_out	= left_out;

	assign right_channel_audio_out	= right_out;

	assign write_audio_out			= audio_in_available & audio_out_allowed;
	//assign write_audio_out			= audio_out_allowed;
	//assign write_audio_out			= 1'b1;
	/*****************************************************************************
	 *                              Internal Modules                             *
	 *****************************************************************************/

	Audio_Controller Audio_Controller (
		// Inputs
		.CLOCK_50						(CLOCK_50),
		.reset						(~KEY[0]),

		.clear_audio_in_memory		(),
		.read_audio_in				(read_audio_in),
		
		.clear_audio_out_memory		(),
		.left_channel_audio_out		(left_channel_audio_out),
		.right_channel_audio_out	(right_channel_audio_out),
		.write_audio_out			(write_audio_out),

		.AUD_ADCDAT					(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK					(AUD_BCLK),
		.AUD_ADCLRCK				(AUD_ADCLRCK),
		.AUD_DACLRCK				(AUD_DACLRCK),


		// Outputs
		.audio_in_available			(audio_in_available),
		.left_channel_audio_in		(left_channel_audio_in),
		.right_channel_audio_in		(right_channel_audio_in),

		.audio_out_allowed			(audio_out_allowed),

		.AUD_XCK					(AUD_XCK),
		.AUD_DACDAT					(AUD_DACDAT),

	);

	avconf #(.USE_MIC_INPUT(1)) avc (
		.I2C_SCLK					(I2C_SCLK),
		.I2C_SDAT					(I2C_SDAT),
		.CLOCK_50					(CLOCK_50),
		.reset						(~KEY[0]),
		.key1							(KEY[1]),
		.key2							(KEY[2])
	);
	
	wire [6:0] play_mary;
	assign play_mary = (counter == 8'd1) ? 7'b0010000 : // e d c d e e e, 
												(counter == 8'd2) ? 7'b0 :
	 
						 (counter == 8'd3) ? 7'b0100000 :
						 						 (counter == 8'd4) ? 7'b0 :

						 (counter == 8'd5) ? 7'b1000000 : 
						 						 (counter == 8'd6) ? 7'b0 :

						 (counter == 8'd7) ? 7'b0100000 : 
						 						 (counter == 8'd8) ? 7'b0 :

						 (counter == 8'd9) ? 7'b0010000 : 
						 						 (counter == 8'd10) ? 7'b0 :

						 (counter == 8'd11) ? 7'b0010000 : 
						 						 (counter == 8'd12) ? 7'b0 :

						 (counter == 8'd13) ? 7'b0010000 : 
												(counter == 8'd14) ? 7'b0 :
												
						 (counter == 8'd15) ? 7'b0 : //REST
	 
						 (counter == 8'd16) ? 7'b0100000 :
						 						 (counter == 8'd17) ? 7'b0 :

						 (counter == 8'd18) ? 7'b0100000 : 
						 						 (counter == 8'd19) ? 7'b0 :

						 (counter == 8'd20) ? 7'b0100000 : 
						 						 (counter == 8'd21) ? 7'b0 :
												 
						 (counter == 8'd22) ? 7'b0 : //REST

						 (counter == 8'd23) ? 7'b0010000 : 
						 						 (counter == 8'd24) ? 7'b0 :

						 (counter == 8'd25) ? 7'b0000100 : 
						 						 (counter == 8'd26) ? 7'b0 :
						 (counter == 8'd27) ? 7'b0000100 :
						 						 (counter == 8'd28) ? 7'b0 :
												 
						(counter == 8'd29) ? 7'b0 : //REST


						 (counter == 8'd30) ? 7'b0010000 : 
						 						 (counter == 8'd31) ? 7'b0 :

						 (counter == 8'd32) ? 7'b0100000 : 
						 						 (counter == 8'd33) ? 7'b0 :

						 (counter == 8'd34) ? 7'b1000000 : 
						 						 (counter == 8'd35) ? 7'b0 :

						 (counter == 8'd36) ? 7'b0100000 : 
						 						 (counter == 8'd37) ? 7'b0 :

						 (counter == 8'd38) ? 7'b0010000 : 
												(counter == 8'd39) ? 7'b0 :
	 
						 (counter == 8'd40) ? 7'b0010000 :
						 						 (counter == 8'd41) ? 7'b0 :

						 (counter == 8'd42) ? 7'b0010000 : 
						 						 (counter == 8'd43) ? 7'b0 :

						 (counter == 8'd44) ? 7'b0010000 : 
						 						 (counter == 8'd45) ? 7'b0 :

						 (counter == 8'd46) ? 7'b0100000 : 
						 						 (counter == 8'd47) ? 7'b0 :

						 (counter == 8'd48) ? 7'b0100000 : 
						 						 (counter == 8'd49) ? 7'b0 :
						 (counter == 8'd50) ? 7'b0010000 : 
						 						 (counter == 8'd51) ? 7'b0 :

						 (counter == 8'd52) ? 7'b0100000 : 
						 						 (counter == 8'd53) ? 7'b0 :

						 (counter == 8'd54) ? 7'b1000000 : 
						 						 (counter == 8'd55) ? 7'b0 :
						 7'b0;


///////// PROCESSOR SHIT //////////////////////////////////////////////////////////////////////////////////////////
	wire reset;
	/** IMEM **/
    // Figure out how to generate a Quartus syncram component and commit the generated verilog file.
    // Make sure you configure it correctly!
    wire [11:0] address_imem;
    wire [31:0] q_imem;
    imem my_imem(
        .address    (address_imem),            // address of data
        .clock      (clock),                  // you may need to invert the clock
        .q          (q_imem)                   // the raw instruction
    );

    /** DMEM **/
    // Figure out how to generate a Quartus syncram component and commit the generated verilog file.
    // Make sure you configure it correctly!
    wire [11:0] address_dmem;
    wire [31:0] data;
    wire wren;
    wire [31:0] q_dmem;
    dmem my_dmem(
        .address    (address_dmem),       // address of data
        .clock      (clock),                  // may need to invert the clock
        .data	    (data),    // data you want to write
        .wren	    (wren),      // write enable
        .q          (q_dmem)    // data from dmem
    );

    /** REGFILE **/
    // Instantiate your regfile
    wire ctrl_writeEnable;
    wire [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    wire [31:0] data_writeReg;
    wire [31:0] data_readRegA, data_readRegB;
    regfile my_regfile(
        clock,
        ctrl_writeEnable,
        reset,
        ctrl_writeReg,
        ctrl_readRegA,
        ctrl_readRegB,
        data_writeReg,
        data_readRegA,
        data_readRegB
    );

    /** PROCESSOR **/
    processor my_processor(
        // Control signals
        ~clock,                          // I: The master clock
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
    );
endmodule
