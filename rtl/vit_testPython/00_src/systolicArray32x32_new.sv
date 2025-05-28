`timescale 1ns / 1ps


module systolicArray32x32_new (
    input  logic                            i_clk,
    input  logic                            i_arst,
    input  logic                            i_validInput,
    input  logic signed [31:0][31:0][7:0]   i_a,
    input  logic signed [31:0][31:0][7:0]   i_b,
    output logic signed [31:0][31:0][31:0]  o_c,
    output logic                            o_validResult
);

  typedef enum logic [2:0] {
    IDLE,
    LOAD,
    COMPUTE,
    STORE,
    DONE
  } state_t;

  state_t state;
  logic [2:0] phase;
  logic validInputSA, validSAResult;

  logic signed [15:0][15:0][7:0] a_sub ;
  logic signed [15:0][15:0][7:0] b_sub;
  logic signed [15:0][15:0][31:0] sa_out;

  logic signed [15:0][15:0][31:0] c00 ;
  logic signed [15:0][15:0][31:0] c01 ;
  logic signed [15:0][15:0][31:0] c10 ;
  logic signed [15:0][15:0][31:0] c11 ;


  systolicArray16x16 u_SA (
      .i_clk(i_clk),
      .i_arst(i_arst),
      .i_a(a_sub),
      .i_b(b_sub),
      .i_validInput(validInputSA),
      .o_c(sa_out),
      .o_validResult(validSAResult)
  );

  task extract_submatrices(input logic [2:0] ph);
    for (int i = 0; i < 32; i++) begin
      for (int j = 0; j < 32; j++) begin
        case (ph)
          3'd0: begin a_sub[i][j] = i_a[i][j];        b_sub[i][j] = i_b[i][j];        end // A00*B00
          3'd1: begin a_sub[i][j] = i_a[i][j+16];     b_sub[i][j] = i_b[i+16][j];     end // A01*B10
          3'd2: begin a_sub[i][j] = i_a[i][j];        b_sub[i][j] = i_b[i][j+16];     end // A00*B01
          3'd3: begin a_sub[i][j] = i_a[i][j+16];     b_sub[i][j] = i_b[i+16][j+16];  end // A01*B11
          3'd4: begin a_sub[i][j] = i_a[i+16][j];     b_sub[i][j] = i_b[i][j];        end // A10*B00
          3'd5: begin a_sub[i][j] = i_a[i+16][j+16];  b_sub[i][j] = i_b[i+16][j];     end // A11*B10
          3'd6: begin a_sub[i][j] = i_a[i+16][j];     b_sub[i][j] = i_b[i][j+16];     end // A10*B01
          3'd7: begin a_sub[i][j] = i_a[i+16][j+16];  b_sub[i][j] = i_b[i+16][j+16];  end // A11*B11
        default: ph = 3'd0;
        endcase

      end
    end
  endtask

  task store_to_buffer(input logic [2:0] ph);
    for (int i = 0; i < 16; i++) begin
      for (int j = 0; j < 16; j++) begin
        case (ph)
          3'd0: c00[i][j] = sa_out[i][j];
          3'd1: c00[i][j] = c00[i][j] + sa_out[i][j];

          3'd2: c01[i][j] = sa_out[i][j];
          3'd3: c01[i][j] = c01[i][j] + sa_out[i][j];

          3'd4: c10[i][j] = sa_out[i][j];
          3'd5: c10[i][j] = c10[i][j] + sa_out[i][j];

          3'd6: c11[i][j] = sa_out[i][j];
          3'd7: c11[i][j] = c11[i][j] + sa_out[i][j];
          default: ph = 3'd0;
        endcase
      end
    end
  endtask

  always_ff @(posedge i_clk or posedge i_arst) begin
    if (i_arst) begin
      state           <= IDLE;
      phase           <= 0;
      o_validResult   <= 0;
      validInputSA    <= 0;
      c00 <= '0; c01 <= '0; c10 <= '0; c11 <= '0;
    end else begin
      case (state)
        IDLE: begin
          o_validResult <= 0;
          if (i_validInput) begin
            phase <= 0;
            extract_submatrices(0);
            validInputSA <= 1;
            state <= COMPUTE;
          end
        end

        COMPUTE: begin
          validInputSA <= 0;
          if (validSAResult) begin
            state <= STORE;
          end
        end

        STORE: begin
          store_to_buffer(phase);
          phase <= phase + 1;
          if (phase == 7) begin
            state <= DONE;
          end else begin
            extract_submatrices(phase + 1);
            validInputSA <= 1;
            state <= COMPUTE;
          end
        end

        DONE: begin
          for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
              o_c[i][j]         <= c00[i][j];
              o_c[i][j+16]      <= c01[i][j];
              o_c[i+16][j]      <= c10[i][j];
              o_c[i+16][j+16]   <= c11[i][j];
            end
          end
          o_validResult <= 1;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end

endmodule

//`timescale 1ns / 1ps
//module systolicArray32x32_new (
//    input  logic                            i_clk,
//    input  logic                            i_arst,
//    input  logic                            i_validInput,
//    input  logic signed [31:0][31:0][7:0]   i_a,
//    input  logic signed [31:0][31:0][7:0]   i_b,
//    output logic signed [31:0][31:0][15:0]  o_c,
//    output logic                            o_validResult
//);

//  logic signed [15:0][15:0][15:0] c00, c01, c10, c11;
//  logic valid0, valid1, valid2, valid3;

//  logic signed [31:0][31:0][15:0] o_c_pipe;
//  logic o_valid_pipe;
  
//  logic signed [15:0][15:0][7:0] a00, a01, a10, a11;
//  logic signed [15:0][15:0][7:0] b00, b01, b10, b11;

//  genvar i, j;
//  generate
//    for (i = 0; i < 16; i++) begin : gen_row
//      for (j = 0; j < 16; j++) begin : gen_col
//        assign a00[i][j] = i_a[i][j];
//        assign a01[i][j] = i_a[i][j+16];
//        assign a10[i][j] = i_a[i+16][j];
//        assign a11[i][j] = i_a[i+16][j+16];

//        assign b00[i][j] = i_b[i][j];
//        assign b01[i][j] = i_b[i][j+16];
//        assign b10[i][j] = i_b[i+16][j];
//        assign b11[i][j] = i_b[i+16][j+16];
//      end
//    end
//  endgenerate

//  // SA0
//  sa16x16_double_phase u_sa00 (
//      .i_clk(i_clk),
//      .i_arst(i_arst),
//      .i_validInput(i_validInput),
//      .i_a0(a00),
//      .i_a1(a01),
//      .i_b0(b00),
//      .i_b1(b01),
//      .o_c(c00),
//      .o_validResult(valid0)
//  );

//  // SA1
//  sa16x16_double_phase u_sa01 (
//      .i_clk(i_clk),
//      .i_arst(i_arst),
//      .i_validInput(i_validInput),
//      .i_a0(a00),
//      .i_a1(a10),
//      .i_b0(b01),
//      .i_b1(b11),
//      .o_c(c01),
//      .o_validResult(valid1)
//  );

//  // SA2
//  sa16x16_double_phase u_sa10 (
//      .i_clk(i_clk),
//      .i_arst(i_arst),
//      .i_validInput(i_validInput),
//      .i_a0(a10),
//      .i_a1(a11),
//      .i_b0(b00),
//      .i_b1(b10),
//      .o_c(c10),
//      .o_validResult(valid2)
//  );

//  // SA3
//  sa16x16_double_phase u_sa11 (
//      .i_clk(i_clk),
//      .i_arst(i_arst),
//      .i_validInput(i_validInput),
//      .i_a0(a10),
//      .i_a1(a11),
//      .i_b0(b01),
//      .i_b1(b11),
//      .o_c(c11),
//      .o_validResult(valid3)
//  );

//  assign o_validResult = o_valid_pipe;
//  assign o_c = o_c_pipe;

//  integer m, n;
//  always_ff @(posedge i_clk or posedge i_arst) begin
//    if (i_arst) begin
//      o_valid_pipe <= 0;
//      o_c_pipe <= '0;
//    end else if (valid0 && valid1 && valid2 && valid3) begin
//      for (m = 0; m < 16; m++) begin
//        for (n = 0; n < 16; n++) begin
//          o_c_pipe[m][n]       <= c00[m][n];
//          o_c_pipe[m][n+16]    <= c01[m][n];
//          o_c_pipe[m+16][n]    <= c10[m][n];
//          o_c_pipe[m+16][n+16] <= c11[m][n];
//        end
//      end
//      o_valid_pipe <= 1;
//    end else begin
//      o_valid_pipe <= 0;
//    end
//  end

//endmodule



