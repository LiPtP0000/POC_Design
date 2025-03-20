// Date: 2025.3.20
// Author: LiPtP
// Description: Simple 8-bit processor generating status and data for POC

module PROCESSOR (
    i_clk,
    i_rst_n,
    i_irq,
    i_dout,
    i_data,
    o_din,
    o_addr,
    o_rw
);


  input wire i_clk;
  input wire i_rst_n;
  input wire i_irq;
  input wire [7:0] i_dout;  // Data from POC (specifically status info)
  input wire [7:0] i_data;  // Data from top module

  output reg [7:0] o_din;  // Data to POC
  output wire o_addr;
  output wire o_rw;

  // Internal registers
  reg [7:0] poc_status;
  reg address;
  reg rw;

  // State registers
  reg [2:0] state, next_state;

  // Status tracking signals
  reg set_data_done;
  reg read_status_done;

  // Mode signal from poc_status[0]
  wire mode = poc_status[0];
  wire interrupt = i_irq;

  // State encoding
  parameter STATUS = 1'b0;
  parameter BUFFER = 1'b1;

  parameter IDLE = 3'b000;
  parameter READ_FROM_POC = 3'b001;
  parameter SET_DATA = 3'b010;
  parameter WRITE_DATA = 3'b011;
  parameter DELAY = 3'b100;
  parameter WRITE_STATUS = 3'b101;

  // State transition
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) state <= IDLE;
    else state <= next_state;
  end

  // Next state logic
  always @(*) begin
    case (state)
      IDLE: begin
        if (mode == 1'b0) next_state = READ_FROM_POC;
        else if (interrupt == 1'b0) next_state = SET_DATA;
        else next_state = IDLE;
      end
      READ_FROM_POC: begin
        if (read_status_done && poc_status[7] == 1'b1) next_state = SET_DATA;
        else next_state = READ_FROM_POC;
      end
      SET_DATA: begin
        if (set_data_done) next_state = WRITE_DATA;
        else next_state = SET_DATA;
      end
      WRITE_DATA: begin
        next_state = DELAY;  // wait one clock cycle for poc read delay
      end
      DELAY: begin
        next_state = WRITE_STATUS;
      end
      WRITE_STATUS: begin
        next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  // Control logic for address and rw
  always @(*) begin
    case (state)
      IDLE: begin
        address = STATUS;
        rw = 1'b0;
      end
      READ_FROM_POC: begin
        rw = 1'b0;
        address = STATUS;
      end
      SET_DATA: begin
        rw = 1'b0;
        address = BUFFER;
      end
      WRITE_DATA: begin
        rw = 1'b1;
        address = BUFFER;
      end
      WRITE_STATUS: begin
        rw = 1'b1;
        address = STATUS;
      end
    endcase
  end

  // Output data control
  always @(*) begin
    set_data_done = 1'b0;
    if (state == WRITE_DATA || state == IDLE) begin
      set_data_done = 1'b0;
    end else begin
      if (address == STATUS) o_din = poc_status;
      else begin
        o_din = i_data;
        set_data_done = 1'b1;
      end
    end
  end

  // poc_status and read_status_done update
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_status_done <= 1'b0;
      poc_status <= 8'b0;
    end else begin
      case (state)
        IDLE: begin
          read_status_done <= 1'b0;
        end
        READ_FROM_POC: begin
          poc_status <= i_dout;
          read_status_done <= 1'b1;
        end
        SET_DATA: begin
          poc_status[7] <= 1'b0;
        end
      endcase
    end
  end

  // Assign output signals
  assign o_rw   = rw;
  assign o_addr = address;

endmodule
