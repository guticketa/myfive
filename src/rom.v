module rom #(
    parameter filename = ""
) (
    input clk,
    input [13:0] addr,
    input [31:0] wdata,
    input [3:0] wstrb,
    output [31:0] rdata,
    input valid,
    output ready
);
    reg [31:0] mem [0:4095];
    initial $readmemh(filename, mem);
    assign rdata = mem[addr[13:2]];
    assign ready = valid;
endmodule
