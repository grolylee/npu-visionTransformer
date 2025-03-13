
// PE[0][0] --> PE[0][1] --> PE[0][2] --> PE[0][3]
//   |            |            |            |
//   v            v            v            v
// PE[1][0] --> PE[1][1] --> PE[1][2] --> PE[1][3]
//   |            |            |            |
//   v            v            v            v
// PE[2][0] --> PE[2][1] --> PE[2][2] --> PE[2][3]
//   |            |            |            |
//   v            v            v            v
// PE[3][0] --> PE[3][1] --> PE[3][2] --> PE[3][3]

//`default_nettype none

module systolicArray #(
    parameter int unsigned N = 16
) (
    input  logic                          i_clk,
    input  logic                          i_arst,
    input  logic                          i_doProcess,
    input  logic [N-1:0][(2*N)-2:0][ 7:0] i_row,
    input  logic [N-1:0][(2*N)-2:0][ 7:0] i_col,
    output logic [N-1:0][    N-1:0][31:0] o_c
);

  /* verilator lint_off UNUSED */
  // Variable used to pass data horizontally between PEs in the same row. The
  // output o_a of one PE is connected to the input i_a of the PE to its right.
  logic [N-1:0][  N:0][7:0] rowInterConnect;

  // Variable used to pass data vertically between PEs in the same column. The
  // output o_b of one PE is connected to the input i_b of the PE below it.
  logic [  N:0][N-1:0][7:0] colInterConnect;
  /* verilator lint_off UNUSED */
  genvar i, j;

  for (i = 0; i < N; i++) begin : gen_PerDummyRowColInterconnect

    // These are dummy interconnects used to pass data from the row matrices to
    // the i_a ports of PE in the first col.
    assign rowInterConnect[i][0] = i_row[i][0];

    // These are dummy interconnects used to pass data  from the col matrices to
    // the i_b ports of PE in the first row.
    assign colInterConnect[0][i] = i_col[i][0];

  end : gen_PerDummyRowColInterconnect

  for (i = 0; i < N; i++) begin : gen_PerRow
    for (j = 0; j < N; j++) begin : gen_PerCol

      pe u_pe (
          .i_clk,
          .i_arst,
          .i_doProcess,
          .i_a(rowInterConnect[i][j]),
          .i_b(colInterConnect[i][j]),
          .o_a(rowInterConnect[i][j+1]),
          .o_b(colInterConnect[i+1][j]),
          .o_y(o_c[i][j])
      );
    end : gen_PerCol
  end : gen_PerRow

endmodule

`resetall
