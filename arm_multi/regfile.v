module regfile (
	clk,
	we4,
	ra1,
	ra2,
	ra3,
	wa4,
	wd4,
	r15,
	rd1,
	rd2,
	rd3
);
	input wire clk;
	input wire we4;
	input wire [3:0] ra1;
	input wire [3:0] ra2;
	input wire [3:0] ra3;
	input wire [3:0] wa4;
	input wire [31:0] wd4;
	input wire [31:0] r15;
	output wire [31:0] rd1;
	output wire [31:0] rd2;
	output wire [31:0] rd3;
	reg [31:0] rf [14:0];
	always @(posedge clk)
		if (we4)
			rf[wa4] <= wd4;
	assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
	assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
	assign rd3 = (ra3 == 4'b1111 ? r15 : rf[ra3]);
endmodule

