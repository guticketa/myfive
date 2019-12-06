module soc #(
    parameter C_PROGRAM_DATA = "",
    parameter C_RAM_DATA = "",
    parameter C_CLOCKFREQ = 50000000,
    parameter C_BAUDRATE = 115200
) (
    input clk,
    input reset,
    input rxd,
    output txd
);
    localparam C_RAM_BASE  = 32'h10000000;
    localparam C_RAM_TOP   = 32'h10007fff;
    localparam C_UART_BASE = 32'h20000000;
    localparam C_UART_TOP  = 32'h20000fff;
    
    wire [31:0] m_cpu_addr, s_rom_addr, s_ram_addr, s_uart_addr;
    wire [31:0] m_cpu_wdata, s_rom_wdata, s_ram_wdata, s_uart_wdata;
    wire [31:0] m_cpu_rdata, s_rom_rdata, s_ram_rdata, s_uart_rdata;
    wire m_cpu_valid, s_rom_valid, s_ram_valid, s_uart_valid;
    wire m_cpu_ready, s_rom_ready, s_ram_ready, s_uart_ready;
    wire [3:0] m_cpu_wstrb, s_rom_wstrb, s_ram_wstrb, s_uart_wstrb;

    assign m_cpu_rdata = 
        ((m_cpu_addr >= C_RAM_BASE) && (m_cpu_addr <= C_RAM_TOP)) ? s_ram_rdata :
        ((m_cpu_addr >= C_UART_BASE) && (m_cpu_addr <= C_UART_TOP)) ? s_uart_rdata : {32{1'bx}};
    assign m_cpu_ready = 
        ((m_cpu_addr >= C_RAM_BASE) && (m_cpu_addr <= C_RAM_TOP)) ? s_ram_ready :
        ((m_cpu_addr >= C_UART_BASE) && (m_cpu_addr <= C_UART_TOP)) ? s_uart_ready : 1'bx;

    cpu #(
        .filename (C_PROGRAM_DATA)
    ) cpu (
        .clk (clk),
        .reset (reset),
        .mem_addr (m_cpu_addr),
        .mem_wdata (m_cpu_wdata),
        .mem_wstrb (m_cpu_wstrb),
        .mem_rdata (m_cpu_rdata),
        .mem_valid (m_cpu_valid),
        .mem_ready (m_cpu_ready)
    );
    assign s_ram_addr = m_cpu_addr;
    assign s_ram_wdata = m_cpu_wdata;
    assign s_ram_wstrb = ((m_cpu_addr >= C_RAM_BASE) && (m_cpu_addr <= C_RAM_TOP)) ? m_cpu_wstrb : 4'h0;
    assign s_ram_valid = ((m_cpu_addr >= C_RAM_BASE) && (m_cpu_addr <= C_RAM_TOP)) ? m_cpu_valid : 1'b0;

    ram #(
        .filename (C_RAM_DATA)
    ) ram (
        .clk (clk),
        .addr (m_cpu_addr[15:0]),
        .wdata (s_ram_wdata),
        .rdata (s_ram_rdata),
        .wstrb (s_ram_wstrb),
        .valid (s_ram_valid),
        .ready (s_ram_ready)
    );

    assign s_uart_addr = m_cpu_addr;
    assign s_uart_wdata = m_cpu_wdata;
    assign s_uart_wstrb = ((m_cpu_addr >= C_UART_BASE) && (m_cpu_addr <= C_UART_TOP)) ? m_cpu_wstrb : 4'h0;
    assign s_uart_valid = ((m_cpu_addr >= C_UART_BASE) && (m_cpu_addr <= C_UART_TOP)) ? m_cpu_valid : 1'b0;

    uart #(
        .C_CLOCKFREQ (C_CLOCKFREQ),
        .C_BAUDRATE (C_BAUDRATE)
    ) uart (
        .clk (clk),
        .reset (reset),
        .bus_addr (s_uart_addr[3:0]),
        .bus_wdata (s_uart_wdata),
        .bus_rdata (s_uart_rdata),
        .bus_wstrb (s_uart_wstrb),
        .bus_valid (s_uart_valid),
        .bus_ready (s_uart_ready),
        .uart_rxd (rxd),
        .uart_txd (txd)
    );

endmodule
