`timescale 1ns / 1ps

module top_bram_wrapper (
    input logic i_clk,
    input logic i_rst,
    input logic i_start,
    output logic signed [31:0][31:0][7:0] o_matrixA,
    output logic signed [31:0][31:0][7:0] o_matrixB,
    output logic o_done
);

  logic [9:0] bram_addr;
  logic signed [7:0] bram_dataA;
  logic signed [7:0] bram_dataB;

  // Ma trận output từ FSM

  blk_mem_gen_AA u_bram (
      .clka (i_clk),
      .ena  (1'b1),
      .wea  (1'b0),
      .addra(bram_addr),
      .dina ('0),
      .douta(bram_dataA)
  );
  // BRAM khởi tạo bằng .coe
  blk_mem_gen_BB u_bram1 (
      .clka (i_clk),
      .ena  (1'b1),
      .wea  (1'b0),
      .addra(bram_addr),
      .dina ('0),
      .douta(bram_dataB)
  );

  // FSM đọc BRAM
  fsm_bram_reader_dual u_fsm (
      .clk(i_clk),
      .rst(i_rst),
      .start(i_start),
      .bram_addr(bram_addr),
      .bram_dataA(bram_dataA),
      .bram_dataB(bram_dataB),
      .matrixA(o_matrixA),
      .matrixB(o_matrixB),
      .done(o_done)
  );

endmodule
