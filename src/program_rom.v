module program_rom #(
    parameter filename = ""
) (
    input clk,
    input [31:0] address,
    output [31:0] data
);
    reg [31:0] mem [0:16383];
    reg [31:0] ff;

    initial $readmemh(filename, mem);

    always @(posedge clk) begin
        ff <= mem[address[2+:14]];
    end
    assign data = ff;

endmodule
