module signed_div(rn,rm,y);
	input wire [31:0] rn,rm;
	output wire [31:0] y;
	
	assign y = (rm != 0 & rn != 0) ? (rn / rm) : 0;

endmodule

module absolute_value(value,abs_value);
	input wire signed [31:0] value;
	output wire [31:0] abs_value;
	assign abs_value = (value < 0) ? -value :value;
endmodule 


module usigned_div(rn,rm,y);
	input wire [31:0] rn,rm;
	output wire [31:0] y;
	wire [31:0] abs_rn,abs_rm;

	absolute_value a_rn(rn,abs_rn);
	absolute_value a_rm(rm,abs_rm);

	assign y = (abs_rm != 0 & abs_rn != 0) ? (abs_rn / abs_rm) : 0;

endmodule

module testbench();
	reg [31:0] rn,rm;
	wire [31:0] y,y_abs;
	signed_div sd(rn,rm,y);
	usigned_div ud(rn,rm,y_abs);
	initial begin
		rn=32'hFFFFFFF4;rm=32'h00000002;#1
		$finish;
	end
	initial begin
		$dumpfile("provando.vcd");
		$dumpvars;
	end

endmodule


// usigned no reconoce complemento 2, vuelve positivo todo valor
