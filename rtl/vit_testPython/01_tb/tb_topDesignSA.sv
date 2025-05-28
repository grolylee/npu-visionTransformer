`timescale 1ns / 1ps

module tb_topDesignSA;

    logic i_clk;
    logic i_rst;
    logic i_start;
    logic signed [31:0][31:0][31:0] o_c ;
    logic signed [15:0] o_c_result [0:1023];
    logic o_validResult;
  
    int num_pass = 0;
    int num_fail = 0;
    
    // DUT
    topDesignSA dut (
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_start(i_start),
      .o_validResult(o_validResult)
    );
  
    initial i_clk = 0;
    always #5 i_clk = ~i_clk;

    task print_matrixA;
      $display("Input Matrix A:");
      for (int i = 0; i < 32; i++) begin
        for (int j = 0; j < 32; j++) begin
          $write("%h ", dut.u_bram_fsm.o_matrixA[i][j]);
        end
        $write("\n");
      end
    endtask
  
    task print_matrixB;
      $display("Input Matrix B:");
      for (int i = 0; i < 32; i++) begin
        for (int j = 0; j < 32; j++) begin
          $write("%h ", dut.u_bram_fsm.o_matrixB[i][j]);
        end
        $write("\n");
      end
    endtask
  
    task print_output_result;
      $display("Output Result:");
//      for (int i = 0; i < 10; i++) begin
//        $write("%0d ", o_c_result[i]);
//        $write("\n");
//      e
      for (int i = 0; i < 32; i++) begin
        for (int j = 0; j < 32; j++) begin
          $write("%h ", dut.o_c[i][j]);
        end
        $write("\n");
      end
    endtask

    task write_output_coe;
      integer file;
      file = $fopen("output.coe", "w");
      if (file) begin
        $fwrite(file, "memory_initialization_radix=16;\n");
        $fwrite(file, "memory_initialization_vector=\n");
        for (int i = 0; i < 32; i++) begin
          for (int j = 0; j < 32; j++) begin
            $fwrite(file, "%h", dut.o_c[i][j]);
            if (!(i == 31 && j == 31)) $fwrite(file, ", ");
            if (j == 31) $fwrite(file, "\n");
          end
        end
        $fwrite(file, ";\n");
        $fclose(file);
        $display("[STATUS] File output.coe success created!");
        num_pass++;
      end else begin
        $display("[FAIL] Not create file output.coe!");
        num_fail++;
      end
    endtask
  
    task check_matrix_input;
      bit pass = 1;
      for (int i = 0; i < 32; i++) begin
        for (int j = 0; j < 32; j++) begin
          if (dut.u_bram_fsm.o_matrixA[i][j] === 'x || dut.u_bram_fsm.o_matrixB[i][j] === 'x) begin
            $display("[FAIL] Detected X at A[%0d][%0d] hoặc B[%0d][%0d]", i, j, i, j);
            pass = 0;
          end
        end
      end
      if (pass) begin
        $display("[PASS] Input A and B valid (not detect X).");
        num_pass++;
      end else begin
        $display("[FAIL] Detect undefined value in input.");
        num_fail++;
      end
    endtask

    initial begin
      i_rst = 1;
      i_start = 0;
      #20;
      i_rst = 0;
      #10;
      i_start = 1;
      #10;
      i_start = 0;
  
      wait (o_validResult); 
  
      print_matrixA();
      print_matrixB();
      print_output_result();
  
      check_matrix_input();
//      check_matrix_multiplication_result();
      write_output_coe();
  
      $display("\n========== VERIFICATION ==========");
      $display("TEST PASS: %0d", num_pass);
      $display("TEST FAIL: %0d", num_fail);
      if (num_fail == 0)
        $display("[FINAL RESULT] ALL TEST PASS!");
      else
        $display("[FINAL RESULT] ❌ DETECTED FAIL!");
  
      $finish();
    end
  
  endmodule





