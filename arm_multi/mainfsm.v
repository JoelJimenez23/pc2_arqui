
module mainfsm (
	clk,
	reset,
	Op,
	Funct,
	IRWrite,
	AdrSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	NextPC,
	RegW,
	MemW,
	Branch,
	ALUOp,
	shift_op,
	div_op,
	mla_op,
	Instr_7_4,
	Rd
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	output wire IRWrite;
	output wire AdrSrc;
	output wire ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ResultSrc;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire Branch;
	output wire ALUOp;
	output wire shift_op;
	output wire div_op;
	output wire mla_op;
	input wire [3:0] Instr_7_4;
	input wire [3:0] Rd;

	reg div_op_aux;
	reg mla_op_aux;
	reg shift_op_aux;

	reg [4:0] state;
	reg [4:0] nextstate;
	reg [11:0] controls;
	localparam [4:0] FETCH =   4'b0000;
	localparam [4:0] DECODE =  4'b0001;
	localparam [4:0] MEMADR =  4'b0010;
	localparam [4:0] MEMREAD = 4'b0011;
	localparam [4:0] MEMWB =   4'b0100;
	localparam [4:0] MEMWRITE= 4'b0101;
	localparam [4:0] EXECUTER= 4'b0110;
	localparam [4:0] EXECUTEI= 4'b0111;
	localparam [4:0] ALUWB =   4'b1000;
	localparam [4:0] BRANCH =  4'b1001;

	// state register
	always @(posedge clk or posedge reset)
		if (reset)
			state <= FETCH;
		else
			state <= nextstate;
	// ADD CODE BELOW
  	// Finish entering the next state logic below.  We've completed the 
  	// first two states, FETCH and DECODE, for you.
  	// next state logic
	always @(*)
		casex (state)
			FETCH: nextstate = DECODE;
			DECODE:
				case (Op)
					2'b00:
						if (Funct[5])
							nextstate = EXECUTEI;
						else
							nextstate = EXECUTER;
					2'b01: begin
						if (Funct[5:2] == 4'b1100 && Funct[0] == 1'b1 && Rd == 4'b1111 && Instr_7_4 == 4'b0001)
							nextstate = EXECUTER;
						else
							nextstate = MEMADR;
					end
					2'b10: nextstate = BRANCH;
					default: nextstate = FETCH;
				endcase
			EXECUTER: nextstate = ALUWB;
			EXECUTEI: nextstate = ALUWB;
			MEMADR: if (Funct[0]) nextstate = MEMREAD;
							else nextstate = MEMWRITE;
			MEMREAD: nextstate = MEMWB;
			MEMWB: nextstate = FETCH;
			MEMWRITE: nextstate = FETCH;
			ALUWB: nextstate = FETCH;
			BRANCH: nextstate = FETCH;
			default: nextstate = FETCH;
		endcase

	// ADD CODE BELOW
	// Finish entering the output logic below.  We've entered the
	// output logic for the first two states, FETCH and DECODE, for you.

	// state-dependent output logic
	always @(*)
		case (state)
			FETCH: controls = 12'b100010101100;
			DECODE: controls=    12'b000000101100;
			EXECUTER: controls = 12'b000000000001;
			EXECUTEI: controls = 12'b000000000011;
			ALUWB: controls =    12'b000100000000;
			MEMADR: controls = 12'b000000000010;
			MEMWRITE: controls =  12'b001001000000;
			MEMREAD: controls = 12'b000001000000;
			MEMWB: controls = 12'b000100010000;
			BRANCH: controls = 12'b010000100010;
			default: controls = 12'bxxxxxxxxxxxx;
		endcase
	assign {NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp} = controls;



	always @(*) begin
		// Inicializa las señales para evitar inferencia de latches
		mla_op_aux = 0;
		div_op_aux = 0;
		shift_op_aux = 0;
		casex (Op)
			2'b00: begin
				if ((state == EXECUTER || state == EXECUTEI )&& Funct[4:1] == 4'b1101) 
					shift_op_aux = 1;
				if (Instr_7_4 == 4'b1001) begin
					mla_op_aux = 1;
		
				end
			end
			2'b01: begin
				if (state == EXECUTER && Funct[5:2] == 4'b1100 && Funct[0] == 1'b1 && Rd == 4'b1111 && Instr_7_4 == 4'b0001) begin
					div_op_aux = 1;
				end
			end
			default: begin
				mla_op_aux = 0;
				div_op_aux = 0;
				shift_op_aux = 0;
			end
		endcase
	end




	assign mla_op = mla_op_aux;
	assign div_op = div_op_aux;
	assign shift_op = shift_op_aux;



endmodule