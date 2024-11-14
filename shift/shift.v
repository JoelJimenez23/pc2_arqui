module shifter(input  [31:0] a, 
               input  [4:0] shamt, 
               input  [1:0] shtype, 
               output reg [31:0] y); 
 
  always @(*) begin
    case (shtype) 
      2'b00:   y = a << shamt; 
	  2'b01:   y = a >> shamt;
      default: y = a; 
    endcase 
  end
endmodule 
