module dsp_mult #(
    parameter BIT_WIDTH = 8
) (
    input logic clk,
    input logic rst_n,
    input  logic [  BIT_WIDTH-1:0] A,
    input  logic [  BIT_WIDTH-1:0] B,
    output logic [2*BIT_WIDTH-1:0] Product
);

  logic [BIT_WIDTH-1:0] A_reg, B_reg;
  logic [2*BIT_WIDTH-1:0] Product_reg;

  always_ff @(posedge clk, posedge rst_n) begin
    if (rst_n) begin
      A_reg <= '0;
      B_reg <= '0;
      Product_reg <= '0;
    end else begin
      A_reg <= A;
      B_reg <= B;
      Product_reg <= A_reg * B_reg;
    end
  end

  assign Product = Product_reg;

endmodule
