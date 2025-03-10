// module pe #(
//     parameter WIDTH = 8
// ) (
//     input logic i_clk,
//     input logic i_rst,
//     input logic i_doPE,

//     input logic [WIDTH-1:0] i_a,
//     input logic [WIDTH-1:0] i_b,

//     output logic [WIDTH-1:0] o_a,
//     output logic [WIDTH-1:0] o_b,
//     output logic [31:0] o_y
// );

//   logic [31:0] mult;
//   logic [31:0] mac_d;
//   logic [31:0] mac_q;
//   logic [WIDTH-1:0] a_q, b_q;

//   always_comb begin
//     mult = i_a * i_b;
//   end

//   always_ff @(posedge i_clk or posedge i_rst) begin : mac_logic
//     if (i_rst) begin
//       mac_q <= '0;
//     end else if (i_doPE) begin
//       mac_q <= mac_d;
//     end
//   end

//   always_comb begin
//     mac_d = mac_q + mult;
//     o_y   = mac_q;
//   end

//   always_ff @(posedge i_clk or posedge i_rst) begin : register_forward_a
//     if (i_rst) begin
//       a_q <= '0;
//     end else if (i_doPE) begin
//       a_q <= i_a;
//     end
//   end

//   always_ff @(posedge i_clk or posedge i_rst) begin : register_forward_b
//     if (i_rst) begin
//       b_q <= '0;
//     end else if (i_doPE) begin
//       b_q <= i_b;
//     end
//   end

//   always_comb begin
//     o_a = a_q;
//     o_b = b_q;
//   end
// endmodule


//`default_nettype none

module pe (
    input  logic        i_clk,
    input  logic        i_arst,
    input  logic        i_doProcess,
    input  logic [ 7:0] i_a,
    input  logic [ 7:0] i_b,
    output logic [ 7:0] o_a,
    output logic [ 7:0] o_b,
    output logic [31:0] o_y
);

  // {{{ MAC

  logic [31:0] mult;

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
  logic [31:0] mac_d, mac_q;

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

  logic [7:0] a_q, b_q;

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
