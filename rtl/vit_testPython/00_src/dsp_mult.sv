`timescale 1ns / 1ps
module dsp_mult #(
    parameter int BIT_WIDTH = 8
) (
    input logic clk,
    input logic rst_n,  // active-low reset
    input logic signed [7:0] A,
    input logic signed [7:0] B,
    output logic signed [31:0] Product
);

  logic signed [7:0] A_reg, B_reg;
  logic signed [31:0] Product_reg;

  always_ff @(posedge clk, posedge rst_n) begin
    if (rst_n) begin
      A_reg <= '0;
      B_reg <= '0;
      Product_reg <= '0;
    end else begin
      A_reg <= A;
      B_reg <= B;
      if (A == 0 || B == 0) begin
        Product_reg <= 31'sd0;
      end else begin
        Product_reg <= A * B;
      end
    end
  end

  assign Product = Product_reg;

endmodule
