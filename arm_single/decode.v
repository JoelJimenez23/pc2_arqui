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
    DivMulSrc,
	shif_op,
	div_op,
	mla_op,
	div_sel,
	Instr_7_4
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
	output reg [1:0] ALUControl;
	output wire DivMulSrc;
	output wire shif_op;
	output wire div_op;
	output wire mla_op;
	output wire div_sel; 
	input wire [3:0] Instr_7_4;

	reg div_op_aux;
	reg mla_op_aux;
	reg shif_op_aux;
	reg DivMulSrc_aux;


	reg [9:0] controls;
	wire Branch;
	wire ALUOp;
	always @(*)
		casex (Op)
			2'b00:
				if (Funct[5])
					controls = 10'b0000101001;
				else
					controls = 10'b0000001001;
			2'b01:
				if (Funct[0])
					controls = 10'b0001111000;
				else
					controls = 10'b1001110100;
			2'b10: controls = 10'b0110100010;
			default: controls = 10'bxxxxxxxxxx;
		endcase
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;
	always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0100: ALUControl = 2'b00;
				4'b0010: ALUControl = 2'b01;
				4'b0000: ALUControl = 2'b10;
				4'b1100: ALUControl = 2'b11;
				4'b1101: ALUControl = 2'b00;
				default: ALUControl = 2'b00;
			endcase
			FlagW[1] = Funct[0];
			FlagW[0] = Funct[0] & ((ALUControl == 2'b00) | (ALUControl == 2'b01));
		end
		else begin
			ALUControl = 2'b00;
			FlagW = 2'b00;
		end
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

	always @(*) begin
		// Inicializa las señales para evitar inferencia de latches
		mla_op_aux = 0;
		div_op_aux = 0;
		DivMulSrc_aux = 0;
		shif_op_aux = 0;
		casex (Op)
			2'b00: begin
				if (Funct[4:1] == 4'b1101) 
					shif_op_aux = 1;
				if (Instr_7_4 == 4'b1001) begin
					mla_op_aux = 1;
					DivMulSrc_aux = 1;
				end
			end
			2'b01: begin
				if (Funct[5:2] == 4'b1100 && Funct[0] == 1'b1 && Rd == 4'b1111 && Instr_7_4 == 4'b0001) begin
					div_op_aux = 1;
					DivMulSrc_aux = 1;
				end
			end
			default: begin
				mla_op_aux = 0;
				div_op_aux = 0;
				DivMulSrc_aux = 0;
				shif_op_aux = 0;
			end
		endcase
	end
	assign div_sel = (Funct[1] == 1) ? 1:0;
	assign mla_op = mla_op_aux;
	assign div_op = div_op_aux;
	assign DivMulSrc = DivMulSrc_aux;
	assign shif_op = shif_op_aux;

endmodule