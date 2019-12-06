module vga_controller(iRST_n,

                      iVGA_CLK,

                      oBLANK_n,

                      oHS,

                      oVS,

                      b_data,

                      g_data,

                      r_data,

							 c,

							 d,

							 e,

							 f,

							 g,

							 a,

							 b,
							 
							 free_play_button,
							 
							 learn_song_button);



	

input iRST_n;

input iVGA_CLK;

input c, d, e, f, g, a, b;
input free_play_button, learn_song_button;

output reg oBLANK_n;

output reg oHS;

output reg oVS;

output [7:0] b_data;

output [7:0] g_data;  

output [7:0] r_data;                        

///////// ////                     

reg [18:0] ADDR;

reg [23:0] bgr_data;

wire VGA_CLK_n;

wire [7:0] index, index_keyboard, index_home_screen;
wire [23:0] bgr_data_raw, bgr_data_raw_keyboard, bgr_data_raw_home_screen;

wire cBLANK_n,cHS,cVS,rst;

////

assign rst = ~iRST_n;

video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),

                              .reset(rst),

                              .blank_n(cBLANK_n),

                              .HS(cHS),

                              .VS(cVS));

////

////Addresss generator

always@(posedge iVGA_CLK,negedge iRST_n)

begin

  if (!iRST_n)

     ADDR<=19'd0;

  else if (cHS==1'b0 && cVS==1'b0)

     ADDR<=19'd0;

  else if (cBLANK_n==1'b1)

     ADDR<=ADDR+1;

end

//////////////////////////

//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_keyboard )
	);

//img_data_home_screen	img_data_home_screen_inst (
//	.address ( ADDR ),
//	.clock ( VGA_CLK_n ),
//	.q ( index_home_screen )
//	);
img_data_lamb	img_data_home_screen_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index_home_screen )
	);
	
/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index_keyboard ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw_keyboard)
	);	
//	
//img_index_home_screen	img_index_home_screen_inst (
//	.address ( index_home_screen ),
//	.clock ( iVGA_CLK ),
//	.q ( bgr_data_raw_home_screen)
//	);
img_index_lamb	img_index_home_screen_inst (
	.address ( index_home_screen ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw_home_screen)
	);
	
//////



/////Begin Mux logic for selecting the image to display
wire [1:0] select_screen_display; //00 is home, 01 is free play, 10 is learn a song. based on the input
assign select_screen_display[0] = free_play_button;//using the input pins to assign this value.
assign select_screen_display[1] = learn_song_button; //using the input pins to assign this value.
select_display_image select_display_image_init(bgr_data_raw, select_screen_display, bgr_data_raw_home_screen, bgr_data_raw_keyboard);

/////End mux logic


//////latch valid data at falling edge;



wire [10:0] x, y;

assign x = ADDR / 640;

assign y = ADDR - x * 640;





wire in_c, in_d, in_e, in_f, in_g, in_a, in_b;

assign in_c = (x <= 10'd262 & y <= 10'd64) | (x >= 10'd262 & y <= 10'd86);

assign in_d = (x <= 10'd262 & y >= 10'd109 & y <= 10'd152) | (x >= 10'd262 & y >= 10'd87 & y <= 10'd174);

assign in_e = (x <= 10'd262 & y >= 10'd196 & y <= 10'd261) | (x >= 10'd262 & y >= 10'd175 & y <= 10'd261);

assign in_f = (x <= 10'd262 & y >= 10'd263 & y <= 10'd327) | (x >= 10'd262 & y >= 10'd263 & y <= 10'd348);

assign in_g = (x <= 10'd262 & y >= 10'd371 & y <= 10'd414) | (x >= 10'd262 & y >= 10'd349 & y <= 10'd435);

assign in_a = (x <= 10'd262 & y >= 10'd458 & y <= 10'd502) | (x >= 10'd262 & y >= 10'd437 & y <= 10'd525);

assign in_b = (x <= 10'd262 & y >= 10'd547) | (x >= 10'd262 & y >= 10'd526);



wire pressed_c, pressed_d, pressed_e, pressed_f, pressed_g, pressed_a, pressed_b;

assign pressed_c = in_c & c;

assign pressed_d = in_d & d;

assign pressed_e = in_e & e;

assign pressed_f = in_f & f;

assign pressed_g = in_g & g;

assign pressed_a = in_a & a;

assign pressed_b = in_b & b;

wire [7:0] tempb1, tempb2, tempb3, tempb4, tempb5, tempb6;
assign tempb1 = pressed_c ? 8'h00 : bgr_data[23:16];
assign tempb2 = pressed_d ? 8'h20: tempb1;
assign tempb3 = pressed_e ? 8'h40: tempb2;
assign tempb4 = pressed_f ? 8'h60: tempb3;
assign tempb5 = pressed_g ? 8'h80: tempb4;
assign tempb6 = pressed_a ? 8'h9F: tempb5;
assign b_data = pressed_b ? 8'hBF: tempb6;

assign g_data = (pressed_c | pressed_d | pressed_e | pressed_f | pressed_g | pressed_a | pressed_b) ? 8'h00 : bgr_data[15:8];

wire [7:0] tempr1, tempr2, tempr3, tempr4, tempr5, tempr6;
assign tempr1 = pressed_c ? 8'hff : bgr_data[7:0];
assign tempr2 = pressed_d ? 8'hdf: tempr1;
assign tempr3 = pressed_e ? 8'hbf: tempr2;
assign tempr4 = pressed_f ? 8'h9f: tempr3;
assign tempr5 = pressed_g ? 8'h80: tempr4;
assign tempr6 = pressed_a ? 8'h60: tempr5;
assign r_data = pressed_b ? 8'h40: tempr6;

always@(posedge VGA_CLK_n)	bgr_data <= bgr_data_raw;

//assign b_data = (pressed_c | pressed_d | pressed_e | pressed_f | pressed_g | pressed_a | pressed_b) ? 8'hee: bgr_data[23:16];
//
//assign g_data = (pressed_c | pressed_d | pressed_e | pressed_f | pressed_g | pressed_a | pressed_b) ? 8'hee: bgr_data[15:8];
//
//assign r_data = (pressed_c | pressed_d | pressed_e | pressed_f | pressed_g | pressed_a | pressed_b) ? 8'hee: bgr_data[7:0]; 

///////////////////

//////Delay the iHD, iVD,iDEN for one clock cycle;

always@(negedge iVGA_CLK)

begin

  oHS<=cHS;

  oVS<=cVS;

  oBLANK_n<=cBLANK_n;

end



endmodule