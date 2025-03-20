// Date: 2025.3.20
// Author: LiPtP
// Description: 8-bit Parallel Output Controller

module POC (
    i_addr,
    o_dout,
    i_din,
    i_rw,
    i_clk,
    i_rst_n,
    i_mode,
    o_irq,
    i_rdy,
    o_tr,
    o_pd
);

  // From Top module

  input wire i_mode;  // 0 = query, 1 = interrupt

  // From/to Processor

  input wire i_addr;  // 0: status, 1: buffer    
  input wire i_clk;
  input wire i_rst_n;
  input wire i_rw;  // 0: read, 1: write
  input wire [7:0] i_din;  // status/data from Processor
  output wire [7:0] o_dout;  // status to CPU
  output wire o_irq;  // 0: interrupt

  // From/to Printer
  input wire i_rdy;
  output wire o_tr;
  output [7:0] o_pd;

  // Inside POC
  reg mode;
  reg [7:0] status;
  reg [7:0] buffer;
  reg [7:0] printer_data;
  reg enable_printer;
  wire interrupt;
  reg ready;



  // State Params

  parameter IDLE = 3'b0;
  // Wait for CPU response
  parameter POLLING_CPU_WRITE = 3'b001;
  // POC will receive data from processor using polling method
  parameter POLLING_TO_PRINTER = 3'b010;
  // POC will transmit data to printer
  parameter INTERRUPT_CPU_WRITE = 3'b011;
  // POC will receive data from processor using interrupt method
  parameter INTERRUPT_TO_PRINTER = 3'b100;
  // POC will transmit data to printer


  reg [2:0] state, next_state;


  // initial 
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state <= IDLE;
      ready <= 'b0;  // maybe there is a more beautiful solution
      mode  <= 'b0;
    end else begin
      state <= next_state;
      ready <= i_rdy;
      mode  <= i_mode;
    end
  end

  // state transition
  always @(*) begin
    case (state)
      IDLE: begin
        if (i_rw == 1'b1) begin
          if (status[0] == 0) begin  // query
            next_state = POLLING_CPU_WRITE;
          end else begin
            if (interrupt == 1'b1) begin
              next_state = INTERRUPT_CPU_WRITE;
            end
          end
        end else begin
          next_state = IDLE;
        end
      end
      POLLING_CPU_WRITE: begin
        if (status[7] == 0) begin
          next_state = POLLING_TO_PRINTER;
        end else begin
          next_state = POLLING_CPU_WRITE;
        end
      end
      POLLING_TO_PRINTER: begin
        if (i_rdy == 'b1 && ready == 'b0) begin
          next_state = IDLE;
        end else begin
          next_state = POLLING_TO_PRINTER;
        end
      end
      INTERRUPT_CPU_WRITE: begin
        if (status[7] == 0) begin
          next_state = INTERRUPT_TO_PRINTER;
        end else begin
          next_state = INTERRUPT_CPU_WRITE;
        end
      end
      INTERRUPT_TO_PRINTER: begin
        if (i_rdy == 'b1 && ready == 'b0) begin
          next_state = IDLE;
        end else begin
          next_state = INTERRUPT_TO_PRINTER;
        end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end


  // status and buffer
  always @(*) begin
    case (state)
      IDLE: begin
        status         = {7'b1000000, mode};  // reset to POC ready
        printer_data   = 8'b0;  // every cycle reset the printer data
        enable_printer = 1'b0;  // every cycle reset the printer status
      end
      POLLING_CPU_WRITE: begin
        // CPU needs to write both buffer and status in this state
        if (i_rw == 1'b1 && i_addr == 1'b1) begin
          buffer = i_din;
        end
        if (i_rw == 1'b1 && i_addr == 1'b0) begin
          status = i_din;
        end
      end
      INTERRUPT_CPU_WRITE: begin
        if (i_rw == 1'b1 && i_addr == 1'b1) begin
          buffer = i_din;
        end
        if (i_rw == 1'b1 && i_addr == 1'b0) begin
          status = i_din;
        end
      end
    endcase
  end

  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) enable_printer <= 1'b0;
    else begin
      if (state == POLLING_TO_PRINTER || state == INTERRUPT_TO_PRINTER) begin

        if (ready == 1'b1 && enable_printer == 1'b0) begin
          printer_data   <= buffer;
          enable_printer <= 1'b1;
        end else if (enable_printer == 1'b1) begin
          enable_printer <= 1'b0;
        end
      end
    end
  end

  // Assignments
  assign o_irq = ~interrupt;
  assign o_tr = enable_printer;
  assign o_pd = printer_data;
  assign o_dout = status;

  assign interrupt = status[7] & status[0];

endmodule
