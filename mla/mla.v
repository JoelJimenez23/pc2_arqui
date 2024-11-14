module mla(rn,rm,y);
	input wire[31:0] rn,rm;
	output wire [31:0] y;
	assign y = rn*rm;
endmodule


module testbench();
	reg [31:0] rn,rm;
	wire [31:0] y;
	mla m(rn,rm,y);
	initial begin
		rn=32'h00000002;rm=32'h00000004;#2
		$finish;
	end
	initial begin
		$dumpfile("provando.vcd");
		$dumpvars;
	end


endmodule


