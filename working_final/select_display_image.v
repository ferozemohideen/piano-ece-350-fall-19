module select_display_image(selected, select_bits, home_screen, keyboard);
	//00 is home, 001 freeplay, 010 learn a song, 100 is listen to mary
	input [23:0] home_screen, keyboard;
	input [2:0] select_bits;
	output [23:0] selected;
	
	wire any_on;
	assign any_on = select_bits[0] | select_bits[1] | select_bits[2];
	assign selected = any_on ? keyboard : home_screen;

endmodule
