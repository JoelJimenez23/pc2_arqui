module top_tb;
  reg clk;
  reg reset;
  wire [31:0] WriteData;
  wire [31:0] DataAdr;
  wire MemWrite;
  
  // Instanciación del módulo top
  top dut (
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );
  
  // Simulación de instrucciones
  reg [31:0] program_mem [0:2];
  
  initial begin
    // Cargar las instrucciones en la memoria del programa
    program_mem[0] = 32'hE2833002; // add r3, r3, #2
    program_mem[1] = 32'hE1A04083; // lsl r4, r3, #1
    program_mem[2] = 32'hE2845001; // add r5, r4, #1
  end

  always begin
    #5 clk = ~clk; // ciclo de reloj cada 5 ns
  end

  initial begin
    clk = 0;
    reset = 1;
    #10 reset = 0;

    #100;

    $finish;
  end
  
  // Módulo para emular la lectura de la memoria de instrucciones
  always @(posedge clk) begin
    if (!reset) begin
      case (dut.arm.PC)
        32'h00000000: dut.imem.RAM[0] = program_mem[0]; // Instrucción 1
        32'h00000004: dut.imem.RAM[1] = program_mem[1]; // Instrucción 2
        32'h00000008: dut.imem.RAM[2] = program_mem[2]; // Instrucción 3
      endcase
    end
  end
  
  // Monitorización de las señales relevantes
  initial begin
    $monitor("PC = %h, Instr = %h, MemWrite = %b, DataAdr = %h, WriteData = %h", 
             dut.arm.PC, dut.arm.Instr, MemWrite, DataAdr, WriteData);
  end
  
  
  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);
  end
endmodule
