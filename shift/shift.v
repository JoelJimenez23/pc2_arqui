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
