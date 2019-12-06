module compare (
    input [31:0] in1,
    input [31:0] in2,
    input [2:0] op,
    output reg out
);
    always @* begin
        case (op)
        3'd0: out = (in1 == in2);
        3'd1: out = (in1 != in2);
        3'd4: out = ($signed(in1) < $signed(in2));
        3'd5: out = ($signed(in1) >= $signed(in2));
        3'd6: out = (in1 < in2);
        3'd7: out = (in1 >= in2);
        default: out = 0;
        endcase
    end
endmodule
