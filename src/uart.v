module uart #(
    parameter C_CLOCKFREQ = 50000000,
    parameter C_BAUDRATE = 115200
) (
    input clk,
    input reset,
    input [3:0] bus_addr,
    input [31:0] bus_wdata,
    output reg [31:0] bus_rdata,
    input [3:0] bus_wstrb,
    input bus_valid,
    output bus_ready,
    input uart_rxd,
    output uart_txd
);
    // tx ready TXE
    // rx ready RXF
    // 0: DATA
    // 1: STATUS (TXE, RXF)
    // 2: CTR
    reg [31:0] ctrl = 0;
    wire [7:0] _tx_data;
    wire tx_valid, tx_ready, _tx_valid, _tx_ready;
    wire [7:0] rx_data, _rx_data;
    wire rx_valid, rx_ready, _rx_valid, _rx_ready;

    assign bus_ready = 1'b1;
    assign tx_valid = bus_valid & bus_wstrb[0] & (bus_addr[3:2] == 2'b00) & ctrl[0];
    assign rx_ready = bus_valid & ~bus_wstrb[0] & (bus_addr[3:2] == 2'b00) & ctrl[0];

    uart_fifo tx_fifo (
        .clk (clk),
        .reset (reset),
        .in_data (bus_wdata[7:0]),
        .in_valid (tx_valid),
        .in_ready (tx_ready),
        .out_data (_tx_data),
        .out_valid (_tx_valid),
        .out_ready (_tx_ready)
    );

    uart_fifo rx_fifo (
        .clk (clk),
        .reset (reset),
        .in_data (_rx_data),
        .in_valid (_rx_valid),
        .in_ready (/* open */),
        .out_data (rx_data),
        .out_valid (rx_valid),
        .out_ready (rx_ready)
    );

    uart_tx_phy #(
        .C_CLOCKFREQ (C_CLOCKFREQ),
        .C_BAUDRATE (C_BAUDRATE)
    ) uart_tx_phy_i (
        .clk (clk),
        .reset (reset),
        .txd (uart_txd),
        .data (_tx_data),
        .valid (_tx_valid),
        .ready (_tx_ready)
    );

    uart_rx_phy #(
        .C_CLOCKFREQ (C_CLOCKFREQ),
        .C_BAUDRATE (C_BAUDRATE)
    ) uart_rx_phy_i (
        .clk (clk),
        .reset (reset),
        .rxd (uart_rxd),
        .data (_rx_data),
        .valid (_rx_valid)
     );

    always @(posedge clk) begin
        if (reset)
            ctrl <= 0;
        else if (bus_addr[3:2] == 2'b10 && bus_wstrb[0] && bus_valid && bus_ready)
            ctrl <= bus_wdata;
    end

    always @* begin
        case (bus_addr[3:2])
        2'b00: bus_rdata = {{24{1'b0}}, rx_data};
        2'b01: bus_rdata = {{30{1'b0}}, tx_ready, rx_ready};
        2'b10: bus_rdata = ctrl;
        default: bus_rdata = 0;
        endcase
    end

endmodule

module uart_fifo (
    input clk,
    input reset,
    input [7:0] in_data,
    input in_valid,
    output in_ready,
    output [7:0] out_data,
    output out_valid,
    input out_ready
);
    reg [7:0] fifo[0:15];
    reg [3:0] ptr;

    assign out_valid = (ptr != 4'hF);
    assign in_ready = (ptr != 4'hE);
   
    always @ (posedge clk) begin
        if (reset)
            ptr <= 4'hF;
        else if (in_valid & in_ready & out_ready & out_valid)
            ptr <= ptr;
        else if (out_ready & out_valid)
            ptr <= ptr - 4'h1;
        else if (in_valid & in_ready)
            ptr <= ptr + 4'h1;
    end

    generate 
        genvar i;
        always @(posedge clk) begin
            if (in_valid & in_ready)
                fifo[0] <= in_data;
        end
        for (i=1; i<16; i=i+1) begin : data_in_bit
            always @(posedge clk) begin
                if (in_valid & in_ready)
                    fifo[i] <= fifo[i-1];
            end
        end
    endgenerate

    assign out_data = fifo[ptr];

endmodule

module uart_rx_phy #(
    parameter C_CLOCKFREQ = 50000000,
    parameter C_BAUDRATE = 115200
) (
    input clk,
    input reset, 
    input rxd,
    output [7:0] data,
    output valid
);
    localparam C_COUNT_MAX = C_CLOCKFREQ / C_BAUDRATE - 1;
    localparam C_CAPTURE = C_COUNT_MAX / 2;

    reg [2:0] rxd_buf = 3'b111;
    reg busy;
    reg [31:0] div_cnt = 0;
    reg [31:0] bit_cnt = 0;
    reg cap_buf = 1'b0;
    reg [9:0] rx_data = 10'd0;

    assign valid = cap_buf;
    assign data = rx_data[8:1];

    always @(posedge clk) begin
        if (reset) begin
            rxd_buf <= 3'b111;
            busy <= 1'b0;
            div_cnt <= 0;
            bit_cnt <= 0;
            cap_buf <= 1'b0;
            rx_data <= 10'd0;
        end
        else begin
            rxd_buf <= {rxd_buf[1:0], rxd};

            if (rxd_buf[2] & ~rxd_buf[1])
                busy <= 1'b1;
            else if (busy && (div_cnt == C_COUNT_MAX) && (bit_cnt == 9))
                busy <= 1'b0;

            if (busy) begin
                if (div_cnt == C_COUNT_MAX)
                    div_cnt <= 0;
                else
                    div_cnt <= div_cnt + 1;
            end

            if (busy & (div_cnt == C_COUNT_MAX)) begin
                if (bit_cnt == 9)
                    bit_cnt <= 0;
                else
                    bit_cnt <= bit_cnt + 1;
            end

            cap_buf <= (div_cnt == C_CAPTURE) & (bit_cnt == 9);
            if (div_cnt == C_CAPTURE)
                rx_data <= {rxd_buf[2], rx_data[9:1]};
        end
    end

endmodule

module uart_tx_phy #(
    parameter C_CLOCKFREQ = 50000000,
    parameter C_BAUDRATE = 115200
) (
    input clk,
    input reset, 
    output txd,
    input [7:0] data,
    input valid,
    output ready
);
    localparam C_COUNT_MAX = C_CLOCKFREQ / C_BAUDRATE - 1;
    localparam C_CAPTURE = C_COUNT_MAX / 2;

    reg busy;
    reg [31:0] div_cnt = 0;
    reg [31:0] bit_cnt = 0;
    reg [9:0] tx_data = {10{1'b0}};

    assign ready = ~busy;
    assign txd = tx_data[0];

    always @(posedge clk) begin
        if (reset) begin
            busy <= 1'b0;
            div_cnt <= 0;
            bit_cnt <= 0;
            tx_data <= 10'd1;
        end
        else begin
            if (ready & valid)
                busy <= 1'b1;
            else if (busy && (div_cnt == C_COUNT_MAX) && (bit_cnt == 9))
                busy <= 1'b0;

            if (busy) begin
                if (div_cnt == C_COUNT_MAX)
                    div_cnt <= 0;
                else
                    div_cnt <= div_cnt + 1;
            end

            if (busy & (div_cnt == C_COUNT_MAX)) begin
                if (bit_cnt == 9)
                    bit_cnt <= 0;
                else
                    bit_cnt <= bit_cnt + 1;
            end

            if (ready & valid)
                tx_data <= {1'b1, data, 1'b0};
            else if (busy & (div_cnt == C_COUNT_MAX))
                tx_data <= {1'b1, tx_data[9:1]};

        end
    end

endmodule
