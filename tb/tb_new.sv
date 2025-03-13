`timescale 1ns / 1ps
//`default_nettype none

module tb_new;

  parameter int unsigned N = 16;
  string file_A = "/home/hieuld/Documents/do-an2/vit_npu/tb/matrix_A.txt";
  string file_B = "/home/hieuld/Documents/do-an2/vit_npu/tb/matrix_B.txt";

  logic  i_clk;
  logic  i_arst;
  logic [N-1:0][N-1:0][7:0] i_a, i_b;
  logic i_validInput;
  logic [N-1:0][N-1:0][31:0] o_c;
  logic o_validResult;

  topSystolicArray #(
      .N(N)
  ) dut (
      .i_clk(i_clk),
      .i_arst(i_arst),
      .i_a(i_a),
      .i_b(i_b),
      .i_validInput(i_validInput),
      .o_c(o_c),
      .o_validResult(o_validResult)
  );

  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
  end

  initial begin
    i_arst = 1;
    #10 i_arst = 0;
  end

  initial begin
    i_validInput = 0;
    i_a = '0;
    i_b = '0;

    #20;
    read_matrix_from_file(file_A, i_a);
    read_matrix_from_file(file_B, i_b);

    i_validInput = 1;
    #10 i_validInput = 0;

    wait (o_validResult == 1);
    #10;

    $display("Matrix A: ");
    print_matrix(i_a);

    $display("Matrix B: ");
    print_matrix(i_b);

    $display("Result Matrix C: ");
    print_result_matrix(o_c);

    $finish;
  end

  task automatic read_matrix_from_file(input string file_name,
                                       output logic [N-1:0][N-1:0][7:0] matrix);
    int file;
    int value;
    file = $fopen(file_name, "r");
    if (file == 0) begin
      $display("Error: Cannot open file %s", file_name);
      $finish;
    end
    // Đọc ma trận
    for (int i = 0; i < N; i++) begin
      for (int j = 0; j < N; j++) begin
        if (!$fscanf(file, "%d", value)) begin
          $display("Error reading matrix at [%0d, %0d] in file %s", i, j, file_name);
          $finish;
        end
        matrix[i][j] = value;
      end
    end

    $fclose(file);
    $display("Successfully loaded matrix from %s", file_name);
  endtask


  task automatic print_matrix(input logic signed [N-1:0][N-1:0][7:0] matrix);
    for (int i = 0; i < N; i++) begin
      for (int j = 0; j < N; j++) begin
        $write("%0d ", matrix[i][j]);
      end
      $write("\n");
    end
  endtask


  task automatic print_result_matrix(input logic signed [N-1:0][N-1:0][31:0] matrix);
    for (int i = 0; i < N; i++) begin
      for (int j = 0; j < N; j++) begin
        $write("%0d ", matrix[i][j]);
      end
      $write("\n");
    end
  endtask

endmodule
