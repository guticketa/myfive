module top (
    input   CLK12MHZ,
    input   ck_rst,
    input   RXD,
    output  TXD,
    output [3:0] led
);
    localparam C_PROGRAM_DATA = "../sw/hello.txt";
    localparam C_RAM_DATA = "../sw/hello_ram.txt";
    localparam C_CLOCKFREQ = 12000000;
    localparam C_BAUDRATE = 9600;
    wire reset = ~ck_rst;
    
    soc #(
        .C_PROGRAM_DATA (C_PROGRAM_DATA),
        .C_RAM_DATA (C_RAM_DATA),
        .C_CLOCKFREQ (C_CLOCKFREQ),
        .C_BAUDRATE (C_BAUDRATE)
    ) soc (
        .clk (CLK12MHZ),
        .reset (reset),
        .rxd (RXD),
        .txd (TXD)
    );

    reg [31:0] cnt_1sec = 0;
    reg [3:0] cnt_led = 4'h0;
    always @(posedge CLK12MHZ) begin
        if (reset) begin
            cnt_1sec <= 0;
            cnt_led <= 4'h0;
        end
        else begin
            if (cnt_1sec == 32'h00B71AFF) begin
                cnt_1sec <= 0;
                cnt_led <= cnt_led + 1;
            end
            else begin
                cnt_1sec <= cnt_1sec + 1;
            end
        end
    end
    assign led = cnt_led;

endmodule
