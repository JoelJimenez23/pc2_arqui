module datapath (
	clk,
	reset,
	RegSrc,
	RegWrite,
	ImmSrc,
	ALUSrc,
	ALUControl,
	MemtoReg,
	PCSrc,
	ALUFlags,
	PC,
	Instr,
	ALUResult,
	WriteData,
	ReadData,
    DivMulSrc, //
	shif_op, //
	div_op, //
	mla_op, //
	div_sel
);
	input wire clk;
	input wire reset;
	input wire [1:0] RegSrc;
	input wire RegWrite;
	input wire [1:0] ImmSrc;
	input wire ALUSrc;
	input wire [1:0] ALUControl;
	input wire MemtoReg;
	input wire PCSrc;
	output wire [3:0] ALUFlags;
	output wire [31:0] PC;
	input wire [31:0] Instr;
	output wire [31:0] ALUResult;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
    input wire [3:0] rot;
	input wire DivMulSrc;
	input wire shif_op;
	input wire div_op;
	input wire mla_op;
	input wire div_sel;

	wire [31:0] PCNext;
	wire [31:0] PCPlus4;
	wire [31:0] PCPlus8;
	wire [31:0] ExtImm,ExtImm_rot;
	wire [3:0] RA1,RA2,RA4,pre_RA1;
    wire [31:0] RD1,RD2,RD3;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [31:0] pre_ALUResult;
	wire [31:0] DIVResult;

	mux2 #(32) pcmux(
		.d0(PCPlus4),
		.d1(Result),
		.s(PCSrc),
		.y(PCNext)
	);
	flopr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.d(PCNext),
		.q(PC)
	);
	adder #(32) pcadd1(
		.a(PC),
		.b(32'b100),
		.y(PCPlus4)
	);
	adder #(32) pcadd2(
		.a(PCPlus4),
		.b(32'b100),
		.y(PCPlus8)
	);
///////

    mux2 #(4) pre_ra1mux(
        .d0(Instr[19:16]),
        .d1(Instr[3:0]),
        .s(DivMulSrc),
        .y(pre_RA1)
    );

	mux2 #(4) ra1mux(
		.d0(pre_RA1),
		.d1(4'b1111),
		.s(RegSrc[0]),
		.y(RA1)
	);
	mux2_1 #(4) ra2mux(
		.d0(Instr[3:0]),
		.d1(Instr[15:12]),
		.s(RegSrc[1]),
		.x(DivMulSrc),
		.y(RA2)
	);
    mux2 #(4) ra4mux(
        .d0(Instr[15:12]),
        .d1(Instr[19:16]),
        .s(DivMulSrc),
        .y(RA4)
    );

////////
	regfile rf(
		.clk(clk),
		.we4(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
        .ra3(Instr[11:8]),
		.wa4(RA4),
		.wd4(Result),
		.r15(PCPlus8),
		.rd1(RD1),
		.rd2(RD2),
        .rd3(RD3)
	);
/////////////
	shifter shift(
		.rs(RD3),
		.shamt5(Instr[11:7]),
		.sh(Instr[6:5]),
		.op(Instr[4]),
		.op1(Instr[7]),
		.rm(RD2),
		.y(WriteData)
	);
/////////////
	mux2 #(32) resmux(
		.d0(ALUResult),
		.d1(ReadData),
		.s(MemtoReg),
		.y(Result)
	);

	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);

	rotate rotation(
		.ExtImm(ExtImm),
		.rot(Instr[11:8]),
		.ExtImm_rot(ExtImm_rot)
	);

	mux2 #(32) srcbmux(
		.d0(WriteData),
		.d1(ExtImm_rot),
		.s(ALUSrc),
		.y(SrcB)
	);

	mla mla1(
		.rn(RD1),
		.rm(RD3),
		.mla_op(mla_op),
		.y(SrcA)
	);

	divider div(
		.rn(RD1),
		.rm(RD3),
		.op(div_sel),
		.y(DIVResult)
	);

	alu alu(
		SrcA,
		SrcB,
		ALUControl,
		pre_ALUResult,
		ALUFlags
	);

	mux4 mx4(
		.d00(pre_ALUResult),
		.d01(SrcB),
		.d10(DIVResult),
		.shift(shif_op),
		.div(div_op),
		.y(ALUResult)
	);

endmodule