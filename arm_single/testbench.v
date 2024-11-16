module testbench;
	reg clk;
	reg reset;
	wire [31:0] WriteData;
	wire [31:0] DataAdr;
	wire MemWrite;
	top dut(
		.clk(clk),
		.reset(reset),
		.WriteData(WriteData),
		.DataAdr(DataAdr),
		.MemWrite(MemWrite)
	);
 	initial begin
		reset = 1;#20
		reset = 0;#200
		$finish;
	end
	always begin
		clk <= 1;#(20);
		clk <= 0;#(20);
	end
	initial begin
		$dumpfile("probando.vcd");
		$dumpvars;
	end
endmodule