module registerfile (
    input clk,
    input reset,
    input stall,
    input [4:0] readaddr1,
    output [31:0] readdata1,
    input [4:0] readaddr2,
    output [31:0] readdata2,
    input [4:0] writeaddr,
    input [31:0] writedata,
    input write
);
    reg [31:0] rf [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i= i+1) begin
            rf[i] = 0;
        end
    end

    always @(posedge clk) begin
        if (~stall & write & (|writeaddr))
            rf[writeaddr] <= writedata;
    end
    assign readdata1 = rf[readaddr1];
    assign readdata2 = rf[readaddr2];

endmodule
