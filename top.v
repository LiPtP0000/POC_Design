// Date: 2025.2.27
// Author: LiPtP
// Description: Top layer of POC, describing interconnections of three lower modules

module TOP (
    i_clk,
    i_rst_n,
    i_data,
    i_mode,
    o_tr,
    o_pd,
    o_rdy,
    o_data,
    o_rw,
    o_addr,
    o_irq,
    o_data_poc_to_processor,
    o_data_processor_to_poc
);
// I/O

input wire i_clk;
input wire i_rst_n;
input wire i_mode;
input wire [7:0] i_data;

output wire [7:0] o_data;
output wire o_irq;
output wire o_addr;
output wire o_rw;
output wire o_tr;
output wire [7:0] o_pd;
output wire o_rdy;
output wire [7:0] o_data_poc_to_processor;
output wire [7:0] o_data_processor_to_poc;
// CPU/POC connections

wire irq;
wire addr;
wire [7:0] data_processor_to_POC;
wire [7:0] data_POC_to_processor;
wire rw;

// POC/Printer connections

wire tr;
wire [7:0] pd;
wire rdy;

// Instantiations

PROCESSOR u_processor (
    .i_clk(i_clk),               // 时钟输入
    .i_rst_n(i_rst_n),           // 复位信号，低有效
    .i_irq(irq),                            // 中断
    .i_data(i_data),                        // Directly from TB
    .i_dout(data_POC_to_processor),         // 从 POC 读取的数据
    .o_din(data_processor_to_POC),          // 发送到 POC 的数据
    .o_addr(addr),                          // 地址信号
    .o_rw(rw)                  // 读/写信号
);

POC u_poc (
    .i_addr(addr),
    .o_dout(data_POC_to_processor),
    .i_din(data_processor_to_POC),
    .i_rw(rw),
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_mode(i_mode),
    .o_irq(irq),
    .i_rdy(rdy),
    .o_tr(tr),
    .o_pd(pd)
);

PRINTER u_printer (
    .i_tr(tr),
    .i_pd(pd),
    .o_rdy(rdy),
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .o_data(o_data)         // directly output to tb
);

// assignments

// CPU/POC 
assign o_irq = irq;
assign o_addr = addr;
assign o_rw = rw;
assign o_data_processor_to_poc = data_processor_to_POC;
assign o_data_poc_to_processor = data_POC_to_processor;

// POC/Printer 
assign o_tr = tr;
assign o_pd = pd;
assign o_rdy = rdy;


endmodule
