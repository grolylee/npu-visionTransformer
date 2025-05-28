`timescale 1ns / 1ps
module systolicArray16x16 (
    input  logic                           i_clk,
    input  logic                           i_arst,
    input  logic signed [15:0][15:0][ 7:0] i_a ,
    input  logic signed [15:0][15:0][ 7:0] i_b ,
    input  logic                           i_validInput,
    output logic signed [15:0][15:0][31:0] o_c  ,
    output logic                           o_validResult
);

  typedef enum logic [1:0] {
    IDLE,
    PHASE1,
    PHASE2,
    DONE
  } state_t;
  state_t state;

  logic signed [7:0][7:0][7:0] a0 ;
  logic signed [7:0][7:0][7:0] a1 ;

  logic signed [7:0][7:0][7:0] a2 ;
  logic signed [7:0][7:0][7:0] a3 ;

  logic signed [7:0][7:0][7:0] b0;
  logic signed [7:0][7:0][7:0] b1;

  logic signed [7:0][7:0][7:0] b2;
  logic signed [7:0][7:0][7:0] b3;

  logic signed [7:0][7:0][31:0] c00a ;
  logic signed [7:0][7:0][31:0] c00b ;

  logic signed [7:0][7:0][31:0] c01a ;
  logic signed [7:0][7:0][31:0] c01b ;

  logic signed [7:0][7:0][31:0] c10a ;
  logic signed [7:0][7:0][31:0] c10b ;

  logic signed [7:0][7:0][31:0] c11a ;
  logic signed [7:0][7:0][31:0] c11b ;


  logic signed [7:0][7:0][31:0] sa_out0;
  logic signed [7:0][7:0][31:0] sa_out1;
  logic signed [7:0][7:0][31:0] sa_out2;
  logic signed [7:0][7:0][31:0] sa_out3;


  logic validInputSA;
  logic v0, v1, v2, v3;

  // 4 Systolic Arrays 
  // phase 1: c00a, c01a, c10a, c11a
  // phase 2: c00b, c01b, c10b, c11b
  topSystolicArray u_SA0 (
      .i_clk,
      .i_arst,
      .i_a(a0),
      .i_b(b0),
      .i_validInput(validInputSA),
      .o_c(sa_out0),
      .o_validResult(v0)
  );
  topSystolicArray u_SA1 (
      .i_clk,
      .i_arst,
      .i_a(a1),
      .i_b(b1),
      .i_validInput(validInputSA),
      .o_c(sa_out1),
      .o_validResult(v1)
  );
  topSystolicArray u_SA2 (
      .i_clk,
      .i_arst,
      .i_a(a2),
      .i_b(b2),
      .i_validInput(validInputSA),
      .o_c(sa_out2),
      .o_validResult(v2)
  );
  topSystolicArray u_SA3 (
      .i_clk,
      .i_arst,
      .i_a(a3),
      .i_b(b3),
      .i_validInput(validInputSA),
      .o_c(sa_out3),
      .o_validResult(v3)
  );

  always_ff @(posedge i_clk or posedge i_arst) begin
    if (i_arst) begin
      state <= IDLE;
      validInputSA <= 0;
      o_validResult <= 0;
    end else begin
      case (state)
        IDLE: begin
          o_validResult <= 0;
          if (i_validInput) begin
            load_phase1();
            validInputSA <= 1;
            state <= PHASE1;
          end
        end

        PHASE1: begin
          validInputSA <= 0;
          if (v0 && v1 && v2 && v3) begin
            c00a <= sa_out0;
            c01a <= sa_out1;
            c10a <= sa_out2;
            c11a <= sa_out3;

            load_phase2();
            validInputSA <= 1;
            state <= PHASE2;
          end
        end

        PHASE2: begin
          validInputSA <= 0;
          if (v0 && v1 && v2 && v3) begin
            c00b <= sa_out0;
            c01b <= sa_out1;
            c10b <= sa_out2;
            c11b <= sa_out3;
            state <= DONE;
            o_validResult <= 1;
          end
        end

        DONE: begin
          for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
              o_c[i][j]       <= c00a[i][j] + c00b[i][j];
              o_c[i][j+8]    <= c01a[i][j] + c01b[i][j];
              o_c[i+8][j]    <= c10a[i][j] + c10b[i][j];
              o_c[i+8][j+8] <= c11a[i][j] + c11b[i][j];
            end
          end
          o_validResult <= 0;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end

  // Phase 1: c00a, c01a, c10a, c11a
  task load_phase1();
    for (int i = 0; i < 8; i++) begin
      for (int j = 0; j < 8; j++) begin
        a0[i][j] = i_a[i][j];  // A00
        a1[i][j] = i_a[i][j];  // A00
        a2[i][j] = i_a[i+8][j];  // A10
        a3[i][j] = i_a[i+8][j];  // A10

        b0[i][j] = i_b[i][j];  // B00
        b1[i][j] = i_b[i][j+8];  // B01
        b2[i][j] = i_b[i][j];  // B00
        b3[i][j] = i_b[i][j+8];  // B01
      end
    end
  endtask

  // Phase 2: c00b, c01b, c10b, c11b
  task load_phase2();
    for (int i = 0; i < 8; i++) begin
      for (int j = 0; j < 8; j++) begin
        a0[i][j] = i_a[i][j+8];  // A01
        a1[i][j] = i_a[i][j+8];  // A01
        a2[i][j] = i_a[i+8][j+8];  // A11
        a3[i][j] = i_a[i+8][j+8];  // A11

        b0[i][j] = i_b[i+8][j];  // B10
        b1[i][j] = i_b[i+8][j+8];  // B11
        b2[i][j] = i_b[i+8][j];  // B10
        b3[i][j] = i_b[i+8][j+8];  // B11
      end
    end
  endtask

endmodule
