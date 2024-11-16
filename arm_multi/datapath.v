module datapath (
	clk,
	reset,
	Adr,
	WriteData,
	ReadData,
	Instr,
	ALUFlags,
	PCWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl,
	rot,
	DivMulSrc,
	shift_op,
	div_op,
	mla_op,
	div_sel
);
	input wire clk;
	input wire reset;
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	output wire [31:0] Instr;
	output wire [3:0] ALUFlags;
	input wire PCWrite;
	input wire RegWrite;
	input wire IRWrite;
	input wire AdrSrc;
	input wire [1:0] RegSrc;
	input wire ALUSrcA;
	input wire [1:0] ALUSrcB;
	input wire [1:0] ResultSrc;
	input wire [1:0] ImmSrc;
	input wire [1:0] ALUControl;

	input wire [3:0] rot;
	input wire DivMulSrc;
	input wire shift_op;
	input wire div_op;
	input wire mla_op;
	input wire div_sel;



	wire [31:0] PCNext;
	wire [31:0] PC;
	wire [31:0] ExtImm,ExtImm_rot;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [31:0] Data;
	wire [31:0] A;
	wire [31:0] ALUResult;
	wire [31:0] ALUOut;
	wire [3:0] RA1;
	wire [3:0] RA2;
	wire [3:0] RA4;
	wire [3:0] pre_RA1;
	wire [31:0] muxPC;

    wire [31:0] RD1,RD2,RD3;
	wire [31:0] rd3;
	wire [31:0] pre_WriteData;
	wire [31:0] pre_ALUResult;
	wire [31:0] DIVResult;
	wire [31:0] pre_A;

	flopenr #(32) PCReg(clk,reset,PCWrite,Result,PC);
	mux2 #(32) adrmux(PC,Result,AdrSrc,Adr);
	
	flopenr #(32) InstrReg(clk,reset,IRWrite,ReadData,Instr);
	flopr #(32) DataReg(clk,reset,ReadData,Data);
	
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

	regfile rf(
		.clk(clk),
		.we4(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
        .ra3(Instr[11:8]),
		.wa4(RA4),
		.wd4(Result),
		.r15(Result),
		.rd1(RD1),
		.rd2(RD2),
        .rd3(RD3)
	);

	flopr #(32) RD1Reg(clk,reset,RD1,pre_A);
	flopr #(32) RD2Reg(clk,reset,RD2,pre_WriteData);
	flopr #(32) RD3Reg(clk,reset,RD3,rd3);


	mla mla1(
		.rn(pre_A),
		.rm(rd3),
		.mla_op(mla_op),
		.y(A)
	);

	divider div(
		.rn(pre_A),
		.rm(rd3),
		.op(div_sel),
		.y(DIVResult)
	);


	mux2 #(32) muxALUSRCA(A,PC,ALUSrcA,SrcA);
	wire [31:0] sz4;


	shifter shift(
		.rs(rd3),
		.shamt5(Instr[11:7]),
		.sh(Instr[6:5]),
		.op(Instr[4]),
		.op1(Instr[7]),
		.rm(pre_WriteData),
		.y(WriteData)
	);

	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);

	rotate rotation(
		.ExtImm(ExtImm),
		.rot(Instr[11:8]), //
		.ExtImm_rot(ExtImm_rot)
	);

	assign sz4 = {29'b0,4'b100};
	mux3 #(32) muxALUSRCB(WriteData,ExtImm_rot,sz4,ALUSrcB,SrcB);
	
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
		.shift(shift_op),
		.div(div_op),
		.y(ALUResult)
	);
	
	flopr #(32) ALUResultReg(clk,reset,ALUResult,ALUOut);
	mux3 #(32) muxResult(ALUOut,Data,ALUResult,ResultSrc,Result);
	
endmodule