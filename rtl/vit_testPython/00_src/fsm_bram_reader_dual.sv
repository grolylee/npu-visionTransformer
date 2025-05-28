`timescale 1ns / 1ps


module fsm_bram_reader_dual (
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   start,
    output logic [ 9:0]            bram_addr,
    input  logic signed [ 7:0]            bram_dataA,
    input  logic signed [ 7:0]            bram_dataB,
    output logic signed [31:0][31:0][7:0] matrixA,
    output logic signed [31:0][31:0][7:0] matrixB,
    output logic                   done
);

  typedef enum logic [1:0] {
    IDLE,
    READ,
    WAIT_LAST,
    DONE
  } state_t;

  state_t state, next_state;

  logic [9:0] addr_cnt;
  logic [9:0] addr_cnt_d1;
  logic [9:0] addr_cnt_d2;
  logic       valid_data;
  logic [1:0] wait_cnt;

  // BRAM address output
  assign bram_addr = addr_cnt;

  // FSM state transition
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  // FSM next-state logic
  always_comb begin
    next_state = state;
    case (state)
      IDLE:      if (start) next_state = READ;
      READ:      if (addr_cnt == 10'd1023) next_state = WAIT_LAST;
      WAIT_LAST: if (wait_cnt == 2'd1) next_state = DONE;  // chờ 1 chu kỳ
      DONE:      next_state = IDLE;
      default:   next_state = state;
    endcase
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      wait_cnt <= 0;
    end else if (state == WAIT_LAST) begin
      wait_cnt <= wait_cnt + 1;
    end else begin
      wait_cnt <= 0;
    end
  end

  // Counter
  always_ff @(posedge clk) begin
    if (state == IDLE) begin
      addr_cnt <= 0;
    end else if (state == READ) begin
      addr_cnt <= addr_cnt + 1;
    end
  end

  // Pipeline address + valid signal
  always_ff @(posedge clk) begin
    valid_data <= (state == READ || state == WAIT_LAST);
  end

  always_ff @(posedge clk) begin
    addr_cnt_d1 <= addr_cnt;
  end

  always_ff @(posedge clk) begin
    addr_cnt_d2 <= addr_cnt_d1;
  end

  // Write matrix only when data is valid
always_ff @(posedge clk) begin
//  if (rst) begin
//    integer i, j;
//    for (i = 0; i < 16; i = i + 1) begin
//      for (j = 0; j < 16; j = j + 1) begin
//        matrixA[i][j] <= 0;
//        matrixB[i][j] <= 0;
//      end
//    end
//  end 
     if (valid_data) begin;
          matrixA[addr_cnt_d2[9:5]][addr_cnt_d2[4:0]] <= bram_dataA; 
          matrixB[addr_cnt_d2[9:5]][addr_cnt_d2[4:0]] <= bram_dataB; 
  end
end


  assign done = (state == DONE);

endmodule

