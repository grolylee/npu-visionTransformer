//`default_nettype none

module pe (
    input  logic               i_clk,
    input  logic               i_arst,
    input  logic               i_doProcess,
    input  logic signed [ 7:0] i_a,
    input  logic signed [ 7:0] i_b,
    output logic signed [ 7:0] o_a,
    output logic signed [ 7:0] o_b,
    output logic signed [31:0] o_y
);

  // // {{{ MAC

  logic signed [31:0] mult;

  dsp_mult #(
      .BIT_WIDTH(8)
  ) u_mult (
      .clk(i_clk),
      .rst_n(i_arst),
      .A(i_a),
      .B(i_b),
      .Product(mult)
  );
  //   assign mult = i_a * i_b;
  logic signed [31:0] mac_d, mac_q;

  always_ff @(posedge i_clk, posedge i_arst) begin
    if (i_arst) begin
      mac_q <= '0;
    end else begin
      mac_q <= mac_d;
    end
  end
  assign mac_d = (i_doProcess) ? mac_q + mult : '0;

  assign o_y   = mac_q;

  // }}} MAC



  // {{{ Register inputs and assign them to outputs

  logic signed [7:0] a_q, b_q;

  always_ff @(posedge i_clk, posedge i_arst) begin
    if (i_arst) begin
      a_q <= '0;
    end else if (i_doProcess) begin
      a_q <= i_a;
    end else begin
      a_q <= a_q;
    end
  end
  always_ff @(posedge i_clk, posedge i_arst) begin
    if (i_arst) begin
      b_q <= '0;
    end else if (i_doProcess) begin
      b_q <= i_b;
    end else begin
      b_q <= b_q;
    end
  end
  assign o_a = a_q;

  assign o_b = b_q;

  // }}} Register inputs and assign them to outputs

endmodule

`resetall
