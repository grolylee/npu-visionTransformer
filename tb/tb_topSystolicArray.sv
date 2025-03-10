`timescale 1ns / 1ps `default_nettype none

module tb_topSystolicArray;

  parameter int unsigned N = 7;

  logic i_clk;
  logic i_arst;
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

    for (int i = 0; i < N; i++) begin
      for (int j = 0; j < N; j++) begin
        i_a[i][j] = i * N + j + 1;
        i_b[i][j] = (i + 1) * (j + 1);
      end
    end

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

  task print_matrix(input [N-1:0][N-1:0][7:0] matrix);
    for (int i = 0; i < N; i++) begin
      for (int j = 0; j < N; j++) begin
        $write("%0d ", matrix[i][j]);
      end
      $write("\n");
    end
  endtask

  task print_result_matrix(input [N-1:0][N-1:0][31:0] matrix);
    for (int i = 0; i < N; i++) begin
      for (int j = 0; j < N; j++) begin
        $write("%0d ", matrix[i][j]);
      end
      $write("\n");
    end
  endtask

endmodule
