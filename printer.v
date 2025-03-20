// Date: 2025.2.27
// Author: LiPtP
// Description: 8-bit Printer with 8 cycles of printing delay and 4 clock cycles of 
module PRINTER (
    i_tr,
    i_pd,
    o_rdy,
    i_clk,
    i_rst_n,
    o_data
);
  // interfaces
  input wire i_clk;
  input wire i_rst_n;
  input wire i_tr;
  input wire [7:0] i_pd;
  output wire o_rdy;
  output wire [7:0] o_data;

  // inside printer
  reg [7:0] delay_buffer[0:3];  // for delaying 4 cycles
  reg ready;
  reg [2:0] count;
  reg state, next_state;

  parameter IDLE = 1'b0;
  parameter BUSY = 1'b1;

  assign o_rdy = ready;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  // state transition
  always @(*) begin
    case (state)
      IDLE: begin
        if (i_tr) begin
          next_state <= BUSY;
        end else begin
          next_state <= IDLE;
        end
      end
      BUSY: begin
        // we will wait 8 clock cycles for printer to print, even though the printing process only needs 4.
        if (count == 3'b111) begin
          next_state <= IDLE;
        end else begin
          next_state <= BUSY;
        end
      end
      default: begin
        next_state <= IDLE;
      end
    endcase

  end

  // counter
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      ready <= 1'b1;
      count <= 3'b0;
    end else begin
      case (state)
        IDLE: begin
          ready <= 1'b1;
          count <= 3'b0;
        end
        BUSY: begin
          ready <= 1'b0;
          count <= count + 1;
        end
        default: begin
          ready <= 1'b1;
          count <= 3'b0;
        end
      endcase
    end
  end

  // delay four cycles to simulate printing process
  always @(posedge i_clk) begin
    if (state == BUSY) begin
      delay_buffer[0] <= i_pd;
    end
  end

  always @(posedge i_clk) begin
    if (state == BUSY) begin
      delay_buffer[1] <= delay_buffer[0];
    end
  end

  always @(posedge i_clk) begin
    if (state == BUSY) begin
      delay_buffer[2] <= delay_buffer[1];
    end
  end

  always @(posedge i_clk) begin
    if (state == BUSY) begin
      delay_buffer[3] <= delay_buffer[2];
    end
  end
  assign o_data = delay_buffer[3];

endmodule
