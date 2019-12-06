module select_display_image(selected, select_bits, home_screen, keyboard);
	//00 is home, 01 freeplay, 10 learn a song
	input [23:0] home_screen, keyboard;
	input [1:0] select_bits;
	output [23:0] selected;
	
	wire[23:0] w1, w2;
	assign w1 = select_bits[0] ? keyboard : home_screen;
	assign selected = select_bits[1] ? keyboard : w1;

endmodule
