
module controller (
	clk,
	reset,
	Instr,
	ALUFlags,
	PCWrite,
	MemWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl,
	DivMulSrc,
	shift_op,
	div_op,
	mla_op,
	div_sel,
	Instr_7_4
);
	input wire clk;
	input wire reset;
	input wire [31:12] Instr;
	input wire [3:0] ALUFlags;
	output wire PCWrite;
	output wire MemWrite;
	output wire RegWrite;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] RegSrc;
	output wire ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ResultSrc;
	output wire [1:0] ImmSrc;
	output wire [1:0] ALUControl;
	output wire DivMulSrc;
	output wire shift_op;
	output wire div_op;
	output wire mla_op;
	output wire div_sel;
	input wire [3:0] Instr_7_4;
	wire [1:0] FlagW;
	wire PCS;
	wire NextPC;
	wire RegW;
	wire MemW;

	decode dec(
		.clk(clk),
		.reset(reset),
		.Op(Instr[27:26]),
		.Funct(Instr[25:20]),
		.Rd(Instr[15:12]),
		.FlagW(FlagW),
		.PCS(PCS),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ResultSrc(ResultSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc),
		.ALUControl(ALUControl),
		.DivMulSrc(DivMulSrc),
		.shift_op(shift_op),
		.div_op(div_op),
		.mla_op(mla_op),
		.div_sel(div_sel),
		.Instr_7_4(Instr_7_4)
	);
	condlogic cl(
		.clk(clk),
		.reset(reset),
		.Cond(Instr[31:28]),
		.ALUFlags(ALUFlags),
		.FlagW(FlagW),
		.PCS(PCS),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.PCWrite(PCWrite),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite)
	);
endmodule