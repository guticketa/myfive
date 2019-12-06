module ram #(
    parameter filename = ""
) (
    input clk,
    input [15:0] addr,
    input [31:0] wdata,
    output [31:0] rdata,
    input [3:0] wstrb,
    input valid,
    output ready
);
    reg [31:0] mem [0:16383];
    initial $readmemh(filename, mem);
    always @(posedge clk) begin
        if (valid & ready) begin
            if (wstrb[0])
                mem[addr[15:2]][0+:8] <= wdata[0+:8];
            if (wstrb[1])
                mem[addr[15:2]][8+:8] <= wdata[8+:8];
            if (wstrb[2])
                mem[addr[15:2]][16+:8] <= wdata[16+:8];
            if (wstrb[3])
                mem[addr[15:2]][24+:8] <= wdata[24+:8];
        end
    end
    assign rdata = mem[addr[15:2]];
    assign ready = valid;
endmodule
