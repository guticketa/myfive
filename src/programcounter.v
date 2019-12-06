module programcounter (
    input clk,
    input reset,
    input [31:0] jump_address,
    input jump_en,
    input stall,
    output [31:0] pc
);
    reg [31:0] _pc_reg = 0;
    reg [31:0] _pc;
    
    assign pc = _pc;
    always @* begin
        if (jump_en)
            _pc = jump_address;
        else
            _pc = _pc_reg;
    end
    always @(posedge clk) begin
        if (reset)
            _pc_reg <= 0;
        else if (~stall)
            _pc_reg <= _pc + 4;
    end
    
endmodule
