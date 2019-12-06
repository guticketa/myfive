`include "params.vh"
module alu (
    input [31:0] in1,
    input [31:0] in2,
    input [2:0] op,
    input neg,
    input sra,
    output reg [31:0] out
);
    always @* begin
        case (op)
        `C_ALU_ADD: begin
            if (neg)
                out = in1 - in2;
            else
                out = in1 + in2;
        end
        `C_ALU_SLL: begin
            out = in1 << in2[4:0];
        end
        `C_ALU_SLT: begin
            if ($signed(in1) < $signed(in2))
                out = 32'd1;
            else
                out = 32'd0;
        end
        `C_ALU_SLTU: begin
            if (in1 < in2)
                out = 32'd1;
            else
                out = 32'd0;
        end
        `C_ALU_XOR: begin
            out = in1 ^ in2;
        end
        `C_ALU_SRL: begin
            if (sra)
                out = $signed(in1) >>> in2[4:0];
            else
                out = in1 >> in2[4:0];
        end
        `C_ALU_OR: begin
            out = in1 | in2;
        end
        `C_ALU_AND: begin
            out = in1 & in2;
        end
        default: begin
            out = in1;
        end
        endcase
    end

endmodule
