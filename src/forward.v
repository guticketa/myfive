module forward (
    input clk,
    input reset,
    input stall,
    input [4:0] reg_waddr,
    input [31:0] reg_wdata,
    input reg_write,
    input [4:0] reg_raddr1,
    input [31:0] reg_rdata1,
    input [4:0] reg_raddr2,
    input [31:0] reg_rdata2,
    output reg [31:0] reg_rdata1_forward,
    output reg [31:0] reg_rdata2_forward
);
    reg [4:0] reg_waddr_buffer;
    reg reg_write_buffer;
    reg [31:0] reg_wdata_buffer;

    always @(posedge clk) begin
        if (reset) begin
            reg_waddr_buffer <= 0;
            reg_wdata_buffer <= 0;
            reg_write_buffer <= 0;
        end
        else if (~stall) begin
            reg_waddr_buffer <= reg_waddr;
            if (reg_waddr == 0)
                reg_wdata_buffer <= 0;
            else
                reg_wdata_buffer <= reg_wdata;
            reg_write_buffer <= reg_write;
        end
    end

    always @* begin
        if (reg_write_buffer & (reg_waddr_buffer == reg_raddr1))
            reg_rdata1_forward = reg_wdata_buffer;
        else
            reg_rdata1_forward = reg_rdata1;
        if (reg_write_buffer & (reg_waddr_buffer == reg_raddr2))
            reg_rdata2_forward = reg_wdata_buffer;
        else
            reg_rdata2_forward = reg_rdata2;
    end

endmodule
