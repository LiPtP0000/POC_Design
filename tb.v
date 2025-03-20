// Date: 2025.3.10
// Author: LiPtP
// Description: Testbench for TOP module
`timescale 1ns / 1ps
module tb_POC;

  // Clock and reset
  reg clk;
  reg reset;

  // Input to modules
  reg [7:0] data_in;
  reg mode;

  // Output from modules
  wire [7:0] printer_data;
  wire printer_tr;
  wire [7:0] poc_pd;
  wire poc_ready;

  wire rw;
  wire addr;
  wire [7:0] data_POC_to_processor;
  wire [7:0] data_processor_to_POC;
  wire irq_n;

  // Clock generation (50MHz, 20ns period)
  always #10 clk = ~clk;

  // Reset sequence
  initial begin
    clk = 0;
    reset = 0;
    mode = 0;
    data_in = 8'b0;

    #50 reset = 1;  // 50ns delay to allow reset propagation
  end

  // Mode switching after 100,000 ns
  initial begin
    #100000 mode = 1;
  end

  // Periodic Data Input
  initial begin
    #100;
    while (1) begin
      if (mode == 0) begin
        data_in = 8'b00000000;
        #320;
        data_in = 8'b00000001;
        #320;
        data_in = 8'b00000010;
        #320;
        data_in = 8'b00000011;
        #320;
        data_in = 8'b00000100;
        #320;
        data_in = 8'b00000101;
        #320;
        data_in = 8'b00000110;
        #320;
        data_in = 8'b00000111;
        #320;
        data_in = 8'b00001000;
        #320;
        data_in = 8'b00001001;
        #320;
        data_in = 8'b00001010;
        #320;
        data_in = 8'b00001011;
        #320;
        data_in = 8'b00001100;
        #320;
        data_in = 8'b00001101;
        #320;
        data_in = 8'b00001110;
        #320;
        data_in = 8'b00001111;
        #320;
        data_in = 8'b00010000;
        #320;
        data_in = 8'b00010001;
        #320;
        data_in = 8'b00010010;
        #320;
        data_in = 8'b00010011;
        #320;
        data_in = 8'b00010100;
        #320;
      end else begin
        data_in = 8'b00000000;
        #320;
        data_in = 8'b00000001;
        #320;
        data_in = 8'b00000010;
        #320;
        data_in = 8'b00000011;
        #320;
        data_in = 8'b00000100;
        #320;
        data_in = 8'b00000101;
        #320;
        data_in = 8'b00000110;
        #320;
        data_in = 8'b00000111;
        #320;
        data_in = 8'b00001000;
        #320;
        data_in = 8'b00001001;
        #320;
        data_in = 8'b00001010;
        #320;
        data_in = 8'b00001011;
        #320;
        data_in = 8'b00001100;
        #320;
        data_in = 8'b00001101;
        #320;
        data_in = 8'b00001110;
        #320;
        data_in = 8'b00001111;
        #320;
        data_in = 8'b00010000;
        #320;
        data_in = 8'b00010001;
        #320;
        data_in = 8'b00010010;
        #320;
        data_in = 8'b00010011;
        #320;
        data_in = 8'b00010100;
        #320;

      end
    end
  end

  // Dump waveforms
  initial begin
    $dumpfile("poc.vcd");
    $dumpvars(0, tb_POC);
    #200000 $finish;
  end

  // Instantiate DUT
  TOP u_dut (
      .i_clk(clk),
      .i_rst_n(reset),
      .i_data(data_in),
      .i_mode(mode),
      .o_tr(printer_tr),
      .o_pd(poc_pd),
      .o_rdy(poc_ready),
      .o_data(printer_data),
      .o_rw(rw),
      .o_addr(addr),
      .o_irq(irq_n),
      .o_data_poc_to_processor(data_POC_to_processor),
      .o_data_processor_to_poc(data_processor_to_POC)
  );

endmodule
