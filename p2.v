
module top (
	clk,
	reset,
	WriteData,
	DataAdr,
	MemWrite
);
	input wire clk;
	input wire reset;
	output wire [31:0] WriteData;
	output wire [31:0] DataAdr;
	output wire MemWrite;
	wire [31:0] PC;
	wire [31:0] Instr;
	wire [31:0] ReadData;
	arm arm(
		.clk(clk),
		.reset(reset),
		.PC(PC),
		.Instr(Instr),
		.MemWrite(MemWrite),
		.ALUResult(DataAdr),
		.WriteData(WriteData),
		.ReadData(ReadData)
	);
	imem imem(
		.a(PC),
		.rd(Instr)
	);
	dmem dmem(
		.clk(clk),
		.we(MemWrite),
		.a(DataAdr),
		.wd(WriteData),
		.rd(ReadData)
	);
endmodule
module dmem (
	clk,
	we,
	a,
	wd,
	rd
);
	input wire clk;
	input wire we;
	input wire [31:0] a;
	input wire [31:0] wd;
	output wire [31:0] rd;
	reg [31:0] RAM [63:0];
	assign rd = RAM[a[31:2]];
	always @(posedge clk)
		if (we)
			RAM[a[31:2]] <= wd;
endmodule
module imem (
	a,
	rd
);
	input wire [31:0] a;
	output wire [31:0] rd;
	reg [31:0] RAM [63:0];
	initial $readmemh("memfile.dat", RAM);
	assign rd = RAM[a[31:2]];
endmodule
module arm (
	clk,
	reset,
	PC,
	Instr,
	MemWrite,
	ALUResult,
	WriteData,
	ReadData
);
	input wire clk;
	input wire reset;
	output wire [31:0] PC;
	input wire [31:0] Instr;
	output wire MemWrite;
	output wire [31:0] ALUResult;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	wire [3:0] ALUFlags;
	wire RegWrite;
	wire ALUSrc;
	wire MemtoReg;
	wire PCSrc;
	wire [1:0] RegSrc;
	wire [1:0] ImmSrc;
	wire [2:0] ALUControl;
	wire DMSrc
	wire Shift;
	wire Div;
	wire Mul;
	wire Div_sel;
	wire [3:0] Instrnew;
	controller c(
		.clk(clk),
		.reset(reset),
		.Instr(Instr[31:12]),
		.ALUFlags(ALUFlags),
		.RegSrc(RegSrc),
		.RegWrite(RegWrite),
		.ImmSrc(ImmSrc),
		.ALUSrc(ALUSrc),
		.ALUControl(ALUControl),
		.MemWrite(MemWrite),
		.MemtoReg(MemtoReg),
		.PCSrc(PCSrc),
		// Nuevos controller
		.Shift(Shift),
		.Div(Div),
		.Mul(Mul),
		.Div_sel(Div_sel),
		.Instrnew(Instr[7:4])
	);
	datapath dp(
		.clk(clk),
		.reset(reset),
		.RegSrc(RegSrc),
		.RegWrite(RegWrite),
		.ImmSrc(ImmSrc),
		.ALUSrc(ALUSrc),
		.ALUControl(ALUControl),
		.MemtoReg(MemtoReg),
		.PCSrc(PCSrc),
		.ALUFlags(ALUFlags),
		.PC(PC),
		.Instr(Instr),
		.ALUResultOut(ALUResult),
		.WriteData(WriteData),
		.ReadData(ReadData),
		// Nuevos controller
		.DMSrc(DMSrc),
		.Shift(Shift),
		.Div(Div),
		.Mul(Mul),
		.Div_sel(Div_sel)
	);
endmodule
module controller (
	clk,
	reset,
	Instr,
	ALUFlags,
	RegSrc,
	RegWrite,
	ImmSrc,
	ALUSrc,
	ALUControl,
	MemWrite,
	MemtoReg,
	PCSrc,
	// Nuevp controller
	DMSrc,
	Shift,	// shift
	Div,	// Div
	Mul	,	// Mul
	Div_sel,
	Instrnew
);
	input wire clk;
	input wire reset;
	input wire [31:12] Instr;
	input wire [3:0] ALUFlags;
	output wire [1:0] RegSrc;
	output wire RegWrite;
	output wire [1:0] ImmSrc;
	output wire ALUSrc;
	output wire [2:0] ALUControl;
	output wire MemWrite;
	output wire MemtoReg;
	output wire PCSrc;
	output wire DMSrc;
	output wire Shift;	// shift
	output wire Div;	// Div
	output wire Div_sel;
	output wire Mul; 	// MLA
	wire [1:0] FlagW;
	wire PCS;
	wire RegW;
	wire MemW;
	decode dec(
		.Op(Instr[27:26]),
		.Funct(Instr[25:20]),
		.Rd(Instr[15:12]),
		.FlagW(FlagW),
		.PCS(PCS),
		.RegW(RegW),
		.MemW(MemW),
		.MemtoReg(MemtoReg),
		.ALUSrc(ALUSrc),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc),
		.ALUControl(ALUControl),
		// Nuevo decoder
		.Shift(Shift),	// shift
		.Div(Div),
		.Mul(Mul)
		.DMSrc(DMSrc),
		.Div_sel(Div_sel),
		.Instrnew(Instrnew)
	);
	condlogic cl(
		.clk(clk),
		.reset(reset),
		.Cond(Instr[31:28]),
		.ALUFlags(ALUFlags),
		.FlagW(FlagW),
		.PCS(PCS),
		.RegW(RegW),
		.MemW(MemW),
		.PCSrc(PCSrc),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite)
	);
endmodule
module decode (
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	RegW,
	MemW,
	MemtoReg,
	ALUSrc,
	ImmSrc,
	RegSrc,
	ALUControl,
	Shift,	// shift
	Div,		// Div
	Mul,	// Mul
	DMSrc,
	Div_sel,
	Instrnew
);
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	output reg [1:0] FlagW;
	output wire PCS;
	output wire RegW;
	output wire MemW;
	output wire MemtoReg;
	output wire ALUSrc;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output reg [2:0] ALUControl;
	output reg Shift;	// shift
	output reg Div;		// Div
	output reg Mul;		// MLA
	reg [9:0] controls;
	wire Branch;
	wire ALUOp;
	always @(*)
		casex (Op)
			2'b00:
				if (Funct[5])
					controls = 10'b0000101001;	// DPI
				else	
					controls = 10'b0000001001;	// DPR
			2'b01:
				if (Funct[0])
					controls = 10'b0001111000;	// LDR

				else
					controls = 10'b1001110100;	// STR
			2'b10: controls = 10'b0110100010; //B
			default: controls = 10'bxxxxxxxxxx;
		endcase
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;
	always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0100: begin
						ALUControl = 3'b000;	// add
						Shift=1'b0;
						Div=1'b0;
						Mul=1'b0;
				end
				4'b0010: begin 
						ALUControl = 3'b001;	// sub
						Shift=1'b0;
						Div=1'b0;
						Mul=1'b0;
				end
				4'b0000:begin 
						ALUControl = 3'b010;	// and 
						Shift=1'b0;
						Div=1'b0;
						Mul=1'b0;
				end
				4'b1100:begin
						ALUControl = 3'b011;	// or
						Shift=1'b0;
						Div=1'b0;
						Mul=1'b0;
				end 		
				4'b0001: begin
						ALUControl = 3'b100;	// EOR
						Shift=1'b0;
						Div=1'b0;
						Mul=1'b0;
				end	
				4'b1101: begin
						ALUControl = 3'b101;    // Shift
						Shift=1'b1;	// shift
						Div=1'b0;	
						Mul=1'b0;
				end
                4'b1001: begin
                        ALUControl = 3'b110;	// DIV
						Shift=1'b0;
						Div=1'b1;
						Mul=1'b0;
                end
				4'b1111: begin
						ALUControl = 3'b111;	// MLA
						Shift=1'b0;
						Div=1'b0;
						Mul=1'b1;
				end
				default:begin 
						ALUControl = 3'bxxx;
						Shift=1'b0;
						Div=1'b0;
						Mul=1'b0;
				end
			endcase
			FlagW[1] = Funct[0];
			FlagW[0] = Funct[0] & ((ALUControl == 2'b00) | (ALUControl == 2'b01));
		end
		else begin
			ALUControl = 3'b000;
			FlagW = 2'b00;
			Shift = 1'b0;
			Div   = 1'b0;
			Mul   = 1'b0;
		end
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
endmodule
module condlogic (
	clk,
	reset,
	Cond,
	ALUFlags,
	FlagW,
	PCS,
	RegW,
	MemW,
	PCSrc,
	RegWrite,
	MemWrite
);
	input wire clk;
	input wire reset;
	input wire [3:0] Cond;
	input wire [3:0] ALUFlags;
	input wire [1:0] FlagW;
	input wire PCS;
	input wire RegW;
	input wire MemW;
	output wire PCSrc;
	output wire RegWrite;
	output wire MemWrite;
	wire [1:0] FlagWrite;
	wire [3:0] Flags;
	wire CondEx;
	flopenr #(2) flagreg1(
		.clk(clk),
		.reset(reset),
		.en(FlagWrite[1]),
		.d(ALUFlags[3:2]),
		.q(Flags[3:2])
	);
	flopenr #(2) flagreg0(
		.clk(clk),
		.reset(reset),
		.en(FlagWrite[0]),
		.d(ALUFlags[1:0]),
		.q(Flags[1:0])
	);
	condcheck cc(
		.Cond(Cond),
		.Flags(Flags),
		.CondEx(CondEx)
	);
	assign FlagWrite = FlagW & {2 {CondEx}};
	assign RegWrite = RegW & CondEx;
	assign MemWrite = MemW & CondEx;
	assign PCSrc = PCS & CondEx;
endmodule
module condcheck (
	Cond,
	Flags,
	CondEx
);
	input wire [3:0] Cond;
	input wire [3:0] Flags;
	output reg CondEx;
	wire neg;
	wire zero;
	wire carry;
	wire overflow;
	wire ge;
	assign {neg, zero, carry, overflow} = Flags;
	assign ge = neg == overflow;
	always @(*)
		case (Cond)
			4'b0000: CondEx = zero;
			4'b0001: CondEx = ~zero;
			4'b0010: CondEx = carry;
			4'b0011: CondEx = ~carry;
			4'b0100: CondEx = neg;
			4'b0101: CondEx = ~neg;
			4'b0110: CondEx = overflow;
			4'b0111: CondEx = ~overflow;
			4'b1000: CondEx = carry & ~zero;
			4'b1001: CondEx = ~(carry & ~zero);
			4'b1010: CondEx = ge;
			4'b1011: CondEx = ~ge;
			4'b1100: CondEx = ~zero & ge;
			4'b1101: CondEx = ~(~zero & ge);
			4'b1110: CondEx = 1'b1;
			default: CondEx = 1'bx;
		endcase
endmodule
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
	ALUResultOut,
	WriteData,
	ReadData,
	Shift,	// shift
	Div,	//  Div
	Mul		// Mul
);
	input wire clk;
	input wire reset;
	input wire [1:0] RegSrc;
	input wire RegWrite;
	input wire [1:0] ImmSrc;
	input wire ALUSrc;
	input wire [2:0] ALUControl;
	input wire MemtoReg;
	input wire PCSrc;
	output wire [3:0] ALUFlags;
	output wire [31:0] PC;
	input wire [31:0] Instr;
	output wire [31:0] ALUResultOut;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	input wire Shift;
	input wire Div;
	input wire Mul;
	wire [31:0] PCNext;
	wire [31:0] PCPlus4;
	wire [31:0] PCPlus8;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [3:0] RA1;
	wire [3:0] RA2;
	wire [31:0] srcBshifted;
	wire [31:0] ALUResult; //LSL
	wire [31:0] SrcAD;
	wire [31:0] SrcAM;
	wire [31:0] ALUResultMV;
    //wire [3:0] A3;
    //wire [3:0] RA11;
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
	mux2 #(4) ra1mux(
		.d0(Instr[19:16]),
		.d1(4'b1111),
		.s(RegSrc[0]),
		.y(RA1)
	);
	mux2 #(4) ra2mux(
		.d0(Instr[3:0]),
		.d1(Instr[15:12]),
		.s(RegSrc[1]),
		.y(RA2)
	);

	// Nuevo mux
	// mux2 #(4) ra11mux(
	// 	.d0(RA11),
	// 	.d1(Instr[3:0]),
	// 	.s(),
	// 	.y(RA1)
	// );

    // mux2 #(4) a3mux(
    //     .d0(Instr[15:12]),
    //     .d1(Instr[19:16]),
    //     .s(),
    //     .y(A3)
    // );

	regfile rf(
		.clk(clk),
		.we3(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
		.wa3(Instr[15:12]), //A3
		.wd3(Result),
		.r15(PCPlus8),
		.rd1(SrcA),
		.rd2(WriteData)
	);

	mla mul(
		.rn(Instr[19:16]),
		.rm(Instr[15:12]),
		.y(SrcAM)
	);

    divider div(
        .rn(Instr[3:0]),
        .rm(Instr[11:8]),
        .op(1'b1),
        .y(SrcAD)
    );



	mux4 #(32) muldivmux(
		.d0(SrcA),
		.d1(SrcAM),
		.d2(SrcAD),
		.d3(32'b1),
		.s({Mul,Div}),
		.y(ALUResultMV)
	);


	mux2 #(32) resmux(
		.d0(ALUResultOut),
		.d1(ReadData),
		.s(MemtoReg),
		.y(Result)
	);
	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);

	shifter sh(		//LSL
		.a(WriteData),
		.shamt(Instr[11:8]),
		.shtype(Instr[6:5]),
		.y(srcBshifted)
	);

	mux2 #(32) srcbmux(
		.d0(srcBshifted),
		.d1(ExtImm),
		.s(ALUSrc),
		.y(SrcB)
	);

	mux2 #(32) aluresultmux(	//LSL
		.d0(ALUResult),
		.d1(SrcB),
		.s(Shift),
		.y(ALUResultOut)
	);
	alu alu(
		SrcAD,
		SrcB,
		ALUControl,
		ALUResultMV,
		ALUFlags
	);
endmodule
module regfile (
	clk,
	we3,
	ra1,
	ra2,
	wa3,
	wd3,
	r15,
	rd1,
	rd2
);
	input wire clk;
	input wire we3;
	input wire [3:0] ra1;
	input wire [3:0] ra2;
	input wire [3:0] wa3;
	input wire [31:0] wd3;
	input wire [31:0] r15;
	output wire [31:0] rd1;
	output wire [31:0] rd2;
	reg [31:0] rf [14:0];
	always @(posedge clk)
		if (we3)
			rf[wa3] <= wd3;
	assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
	assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
endmodule
module extend (
	Instr,
	ImmSrc,
	ExtImm
);
	input wire [23:0] Instr;
	input wire [1:0] ImmSrc;
	output reg [31:0] ExtImm;
	always @(*)
		case (ImmSrc)
			2'b00: ExtImm = {24'b000000000000000000000000, Instr[7:0]};
			2'b01: ExtImm = {20'b00000000000000000000, Instr[11:0]};
			2'b10: ExtImm = {{6 {Instr[23]}}, Instr[23:0], 2'b00};
			default: ExtImm = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
		endcase
endmodule
module adder (
	a,
	b,
	y
);
	parameter WIDTH = 8;
	input wire [WIDTH - 1:0] a;
	input wire [WIDTH - 1:0] b;
	output wire [WIDTH - 1:0] y;
	assign y = a + b;
endmodule
module flopenr (
	clk,
	reset,
	en,
	d,
	q
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire en;
	input wire [WIDTH - 1:0] d;
	output reg [WIDTH - 1:0] q;
	always @(posedge clk or posedge reset)
		if (reset)
			q <= 0;
		else if (en)
			q <= d;
endmodule
module flopr (
	clk,
	reset,
	d,
	q
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire [WIDTH - 1:0] d;
	output reg [WIDTH - 1:0] q;
	always @(posedge clk or posedge reset)
		if (reset)
			q <= 0;
		else
			q <= d;
endmodule
module mux2 (
	d0,
	d1,
	s,
	y
);
	parameter WIDTH = 8;
	input wire [WIDTH - 1:0] d0;
	input wire [WIDTH - 1:0] d1;
	input wire s;
	output wire [WIDTH - 1:0] y;
	assign y = (s ? d1 : d0);
endmodule

module mux4 (
	d0,
	d1,
	d2,
	d3,
	s,
	y
);
	parameter WIDTH = 8;
	input wire [WIDTH - 1:0] d0;
	input wire [WIDTH - 1:0] d1;
	input wire [WIDTH - 1:0] d2;
	input wire [WIDTH - 1:0] d3;
	input wire [1:0] s;
	output wire [WIDTH - 1:0] y;

	assign y = (s == 2'b00) ? d0 :        // Si s == 00, selecciona d0
             (s == 2'b01) ? d1 :        // Si s == 01, selecciona d1
             (s == 2'b10) ? d2 :        // Si s == 10, selecciona d2
             d3;                        // Si s == 11, selecciona d3
endmodule

module alu ( input [31:0] a,b,
             input [2:0] ALUControl,
             output reg [31:0] Result, //assign always block
             output wire [3:0] ALUFlags); //explicit wire for assign with {}
  
  wire negative, zero, carry, overflow; // define wire for each flag (n,z,c,v)
  wire [32:0] sum;
  
  
  assign sum = a + (ALUControl[0]? ~b: b) + ALUControl[0]; //ADDER: two's complement
  
  /*
  ALUControl Logic
  00: sum
  01: sub
  10: and
  11: or
  */
  always @(*)
    casex (ALUControl[2:0]) //case, casex, casez
      3'b00?: Result = sum;
      3'b010: Result = a & b;
      3'b011: Result = a | b;
	  3'b100: Result = a ^ b;
    endcase
  
 //flags: result -> negative, zero
  assign negative = Result[31];
  assign zero = (Result == 32'b0);
  //flags: additional logic -> v, c
  assign carry = (ALUControl[1]==1'b0) & sum[32];
  assign overflow = (ALUControl[1]==1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);

  assign ALUFlags = {negative, zero, carry, overflow};

endmodule

//shifter  LSL 
module shifter(input  [31:0] a, 
               input  [4:0] shamt, 
               input  [1:0] shtype, 
               output reg [31:0] y); 
 
  always @(*) begin
    case (shtype) 
      2'b00:   y = a << shamt; 
	  2'b01:   y = a >> shamt;
	  2'b10:   y = $signed(a) >>> shamt;
	  2'b11:   y = (a >> shamt ) | (a << (32- shamt));
      default: y = a; 
    endcase 
  end
endmodule 

module mla(rn,rm,y);
	input wire[31:0] rn,rm;
	output wire [31:0] y;
	assign y = rn*rm;
endmodule


module signed_div(rn,rm,y);
	input wire signed [31:0] rn,rm;
	output wire signed [31:0] y;
	assign y = rn/rm;	
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

	assign y = (abs_rm != 0 && abs_rn != 0) ? (abs_rn / abs_rm) : 0;

endmodule


module divider(rn,rm,op,y);
	input wire [31:0] rn,rm;
	input wire op;
	output wire [31:0] y;

	wire [31:0] s_y,u_y;
	signed_div s(rn,rm,s_y);
	usigned_div u(rn,rm,u_y);
	
	assign y = (op == 1) ? u_y : s_y;

endmodule
