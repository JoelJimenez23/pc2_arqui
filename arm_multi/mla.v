module mla(rn,rm,mla_op,y);
	input wire[31:0] rn,rm;
	input wire mla_op;
	output wire [31:0] y;
	assign y = (mla_op == 1) ? rn*rm : rn;
endmodule