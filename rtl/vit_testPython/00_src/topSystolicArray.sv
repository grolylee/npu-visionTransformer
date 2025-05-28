
`timescale 1ns / 1ps
module topSystolicArray #(
    parameter int unsigned N = 8
) (
    input  logic                             i_clk,
    input  logic                             i_rst,
    input  logic signed [N-1:0][N-1:0][ 7:0] i_a,           // 2D array of 8-bit signed 4x4 matrix
    input  logic signed [N-1:0][N-1:0][ 7:0] i_b,
    input  logic                             i_validInput,
    output logic signed [N-1:0][N-1:0][31:0] o_c ,
    output logic                             o_validResult
);
  genvar i, j;
  // {{{ Check matrix dimension size is valid

  logic doProcess_d, doProcess_q;

  // localparam bit Nvalid = &{N > 2, N < 257};
  localparam bit Nvalid = (N > 2) && (N < 257);

  if (!Nvalid) begin : gen_ParaCheck
    $error("Matrix dimension size 'N' is invalid.");
  end : gen_ParaCheck

  // }}} Check matrix dimension size is valid

  // {{{ Control counter
  // This counter is used to determine when to assert o_validResult and sets up
  // the necessary control signals.

  // Number of clock cycles required to complete matrix multiplication.
  localparam int unsigned MultCycles = 3 * N;
  // `+1` to support counter_q + 1;
  localparam int unsigned MultCyclesWidth = $clog2(MultCycles + 1);

  logic [MultCyclesWidth-1:0] counter_d, counter_q;

  always_ff @(posedge i_clk, posedge i_arst) begin
    if (i_arst) begin
      counter_q <= 0;
    end else begin
      counter_q <= counter_d;
    end
  end
  always_comb begin
    if (doProcess_d == '1) begin
      counter_d = counter_q + 1'b1;
    end else begin
      counter_d = '0;
    end
  end

  //o_validResult is asserted to signal the end of the matrix multiplication
  // process.
  logic validResult_q;

  always_ff @(posedge i_clk, posedge i_arst) begin
    if (i_arst) begin
      validResult_q <= '0;
    end else if (counter_q == MultCyclesWidth'(MultCycles)) begin
      validResult_q <= '1;
    end else begin
      validResult_q <= '0;
    end
  end
  assign o_validResult = validResult_q;

  // }}} Control counter

  // {{{ Systolic array clock gate

  always_ff @(posedge i_clk, posedge i_arst) begin
    if (i_arst) begin
      doProcess_q <= '0;
    end else begin
      doProcess_q <= doProcess_d;
    end
  end
  always_comb begin
    if (i_validInput) begin
      doProcess_d = '1;
    end else if (counter_q == MultCyclesWidth'(MultCycles + 1)) begin
      doProcess_d = '0;
    end else doProcess_d = doProcess_q;
  end  // }}} Systolic array clock gate {{{ Set-up row and column matrices
  localparam int unsigned PAD = 8 * (N - 1);  //N = 4 -> 24 bits padding
  localparam bit [PAD-1:0] AppendZero = PAD'(0);

  logic signed [N-1:0][(2*N)-2:0][7:0] row_d, row_q;

  logic signed [N-1:0][(2*N)-2:0][7:0] col_d, col_q;

  logic signed [N-1:0][N-1:0][7:0] invertedRowElements;
  logic signed [N-1:0][N-1:0][7:0] invertedColElements;

  for (i = 0; i < N; i++) begin : gen_perRowCol

    always_ff @(posedge i_clk, posedge i_arst) begin
      if (i_arst) begin
        row_q[i] <= '0;
      end else begin
        row_q[i] <= row_d[i];
      end
    end
    always_comb begin
      if (i_validInput) begin
        row_d[i] = {AppendZero, invertedRowElements[i]} << i * 8;
      end else if (counter_q != '0) begin
        row_d[i] = row_q[i] >> 8;
      end else begin
        row_d[i] = row_q[i];
      end
    end
    // Invert the positions of the elements in each row to form the row matrix.
    for (j = 0; j < N; j++) begin : gen_perRowElement

      assign invertedRowElements[i][j] = i_a[i][N-j-1];

    end : gen_perRowElement

    always_ff @(posedge i_clk, posedge i_arst) begin
      if (i_arst) begin
        col_q[i] <= '0;
      end else begin
        col_q[i] <= col_d[i];
      end
    end
    always_comb begin
      if (i_validInput) begin
        col_d[i] = {AppendZero, invertedColElements[i]} << i * 8;
      end else if (counter_q != '0) begin
        col_d[i] = col_q[i] >> 8;
      end else begin
        col_d[i] = col_q[i];
      end
    end
    // Invert the positions of the elements in each col to form the col matrix.
    for (j = 0; j < N; j++) begin : gen_perColElement

      assign invertedColElements[i][j] = i_b[N-j-1][i];

    end : gen_perColElement

  end : gen_perRowCol

  // }}} Set-up rows and columns matrices

  systolicArray #(
      .N(N)
  ) u_systolicArray (
      .i_clk,
      .i_arst,
      .i_doProcess(doProcess_q),
      .i_row(row_q),
      .i_col(col_q),
      .o_c
  );
endmodule

`resetall
