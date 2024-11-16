module decode (
	clk,
	reset,
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	IRWrite,
	AdrSrc,
	ResultSrc,
	ALUSrcA,
	ALUSrcB,
	ImmSrc,
	RegSrc,
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
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	output reg [1:0] FlagW;
	output wire PCS;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ResultSrc;
	output wire ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output reg [1:0] ALUControl;
	
	output wire DivMulSrc; //

	output wire shift_op;
	output wire div_op;
	output wire mla_op;

	output wire div_sel; //

	input wire [3:0] Instr_7_4;

	wire Branch;
	wire ALUOp;

	// Main FSM
	mainfsm fsm(
		.clk(clk),
		.reset(reset),
		.Op(Op),
		.Funct(Funct),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.Branch(Branch),
		.ALUOp(ALUOp),
		.shift_op(shift_op),
		.div_op(div_op),
		.mla_op(mla_op),
		.Instr_7_4(Instr_7_4),
		.Rd(Rd)
	);

	// ADD CODE BELOW
	// Add code for the ALU Decoder and PC Logic.
	// Remember, you may reuse code from previous labs.
	// ALU Decoder
	always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0100: ALUControl = 2'b00;
				4'b0010: ALUControl = 2'b01;
				4'b0000: ALUControl = 2'b10;
				4'b1100: ALUControl = 2'b11;
				default: ALUControl = 2'b00;
			endcase
			FlagW[1] = Funct[0];
			FlagW[0] = Funct[0] & ((ALUControl == 2'b00) | (ALUControl == 2'b01));
		end
		else begin
			ALUControl = 2'b00;
			FlagW = 2'b00;
		end

	// PC Logic
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

	// Add code for the Instruction Decoder (Instr Decoder) below.
	// Recall that the input to Instr Decoder is Op, and the outputs are
	// ImmSrc and RegSrc. We've completed the ImmSrc logic for you.

	// Instr Decoder
	assign ImmSrc = Op;
	assign RegSrc[1] = (Op == 2'b01);
	assign RegSrc[0] = (Op == 2'b10);

	assign div_sel = (Funct[1] == 1) ? 1:0;
	assign DivMulSrc = (Op == 2'b00 && Instr_7_4 == 4'b1001 ) ? 1:
						(Op == 2'b01 && Rd == 4'b1111 && Instr_7_4 == 4'b0001 && Funct[5:2] == 4'b1100 && Funct[0] == 1'b1)? 1:
						0;

endmodule