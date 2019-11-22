module DE2_Audio_Example (
	// Inputs
	CLOCK_50,
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
	SW
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input				CLOCK_27;
input		[3:0]	KEY;
input		[6:0]	SW;

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

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
 
 /*****************************************************************************
 *                         LAB 6 SOUNDS GO HERE                               *
 *****************************************************************************/
 
 wire [31:0] f1;
 wire [31:0] f2;
 wire [31:0] f3;
 wire [31:0] f4;
 
 
 assign f1 = 32'd5000;
 assign f2 = 32'd25000;
 assign f3 = 32'd100000;
 assign f4 = 32'd500000;
 assign f5 = 32'd600000;
 assign f6 = 32'd750000;
 assign f7 = 32'd850000;
 wire alloff;
 wire [31:0] counterout;
 
 
 
 wire[31:0] numcyc;
	wire [31:0] thing2add;
 
 assign numcyc = f1*SW[0] + f2*SW[1] + f3*SW[2] + f4*SW[3] + f5*SW[4] + f6*SW[5] + f7*SW[6];

 nor alloffnor(alloff, SW[0], SW[1], SW[2], SW[3], SW[4], SW[5], SW[6]);

 //assign numcyc = 32'd500000;
 
 counter(CLOCK_50, numcyc, counterout);
 	
 assign thing2add = alloff ? 32'b0 : counterout;
 
 /*****************************************************************************
 *                         LAB 6 SOUNDS END HERE                              *
 *****************************************************************************/


assign read_audio_in			= audio_in_available & audio_out_allowed;

wire [31:0] left_in, right_in, left_out, right_out;
assign left_in = left_channel_audio_in;
assign right_in = right_channel_audio_in;


assign left_channel_audio_out	= left_out + thing2add;
assign right_channel_audio_out	= right_out + thing2add;
assign write_audio_out			= audio_in_available & audio_out_allowed;

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

endmodule
