module mux4(d00,d01,d10,div,shift,y);
	input wire [31:0] d00,d01,d10;
	input wire shift,div;
	output wire [31:0] y;
	assign y = (shift == 1) ? d01 :
		(div == 1) ? d10 : d00;
endmodule