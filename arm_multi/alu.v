module alu(SrcA,SrcB,ALUControl,ALUResult,ALUFlags);
	input  [31:0] SrcA;
	input  [31:0] SrcB;
	input wire [1:0] ALUControl; 
	output wire [3:0] ALUFlags;
	output reg [31:0] ALUResult;
	
	wire neg,zero,carry,overflow;
	wire [31:0] condinvb;
	wire [32:0] sum;

	assign condinvb = ALUControl[0] ? ~SrcB : SrcB;
	assign sum = SrcA + condinvb + ALUControl[0];
	

	assign neg = ALUResult[31];
	assign zero = (ALUResult == 32'b0);
	assign carry = (ALUControl[1] == 1'b0) & sum[32];
	assign overflow = (ALUControl[1] == 1'b0) & ~(SrcA[31] ^ SrcB[31] ^ ALUControl[0]) & (SrcB[31] ^ sum[31]);
	assign ALUFlags = {neg,zero,carry,overflow};

	always@(*)
		begin
			casex (ALUControl[1:0])
				3'b0?:ALUResult = sum;
				3'b10:ALUResult = SrcA & SrcB;
				3'b11:ALUResult = SrcA | SrcB;
			endcase
		end
	


endmodule