`timescale 1ns / 1ps
//module output_flatten (
//    input  logic [31:0][31:0][15:0] matrix,
//    output logic [15:0] flat_array [0:1023]
//);
//    genvar i, j;
//    generate
//        for (i = 0; i < 32; i++) begin : row
//            for (j = 0; j < 32; j++) begin : col
//                assign flat_array[(i << 5) + j] = matrix[i][j];
//            end
//        end
//    endgenerate
//endmodule

module output_flatten (
    input  logic                  i_clk,
    input  logic                  i_rst,
    input  logic                  i_valid,
    input  logic signed [31:0][31:0][31:0] matrix,
    output logic                  done,
    output logic [9:0]           wr_addr,
    output logic                 wr_en,
    output logic [31:0]          wr_data
);

    logic [9:0] index;
    logic [4:0] col;
    logic [4:0] row;

    assign row = index[9:5]; // index / 32
    assign col = index[4:0]; // index % 32

    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            index   <= 0;
            wr_en   <= 0;
            done    <= 0;
        end else if (i_valid && !done) begin
            wr_en   <= 1;
            wr_addr <= index;
            wr_data <= matrix[row][col];

            if (index == 10'd1023) begin
                done  <= 1;
                wr_en <= 0;
            end else begin
                index <= index + 1;
            end
        end else begin
            wr_en <= 0;
        end
    end

endmodule



