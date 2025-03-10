`timescale 1ns/1ps

module tb_dsp_mult;

  parameter BIT_WIDTH = 8;
  logic clk;
  logic rst_n;
  logic [BIT_WIDTH-1:0] A, B;
  logic [2*BIT_WIDTH-1:0] Product;

  // Clock Generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock
  end

  // Instantiate DUT
  dsp_mult #(
    .BIT_WIDTH(BIT_WIDTH)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .A(A),
    .B(B),
    .Product(Product)
  );

  // Reset Task
  task reset();
    rst_n = 0;
    #20;
    rst_n = 1;
    $display("Reset De-asserted at time %0t", $time);
  endtask

  // Stimulus Task
  task stimulus(input [BIT_WIDTH-1:0] a, input [BIT_WIDTH-1:0] b);
    A = a;
    B = b;
    $display("Time=%0t | A=%0d | B=%0d", $time, a, b);
    #10;
  endtask

  // Main Testbench
  initial begin
    $dumpfile("dsp_mult_tb.vcd");
    $dumpvars(0, tb_dsp_mult);

    reset();
    
    // Test case 1: Simple multiplication
    stimulus(8'd10, 8'd5);
    #20;
    $display("Product = %0d (Expected: 50)", Product);

    // Test case 2: Zero Multiplication
    stimulus(8'd0, 8'd15);
    #20;
    $display("Product = %0d (Expected: 0)", Product);

    // Test case 3: Max Value Multiplication
    stimulus(8'd255, 8'd255);
    #20;
    $display("Product = %0d (Expected: %0d)", Product, 255 * 255);

    // Test case 4: Random Values
    stimulus(8'd123, 8'd45);
    #20;
    $display("Product = %0d (Expected: %0d)", Product, 123 * 45);

    $display("Test Completed");
    $finish;
  end

endmodule

