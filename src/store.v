`include "params.vh"
module store (
    input [31:0] address,
    input [31:0] in,
    input [2:0] op,
    input we,
    output reg [31:0] wdata,
    output [3:0] wstrb
);
    reg [3:0] t;
    assign wstrb = (we) ? t : 4'h0;
    always @* begin
        case (op)
        `C_MEMSTORE_BYTE: begin
            case (address[1:0])
            0: begin
                t = 4'b0001;
                wdata = {{24{1'b0}}, in[0+:8]};
            end
            1: begin
                t = 4'b0010;
                wdata = {{16{1'b0}}, in[0+:8], {8{1'b0}}};
            end
            2: begin
                t = 4'b0100;
                wdata = {{8{1'b0}}, in[0+:8], {16{1'b0}}};
            end
            3: begin
                t = 4'b1000;
                wdata = {in[0+:8], {24{1'b0}}};
            end
            default: t = 4'bxxxx;
            endcase
        end
        `C_MEMSTORE_HALF: begin
            case (address[1])
            0: begin
                t = 4'b0011;
                wdata = {{16{1'b0}}, in[0+:16]};
            end
            1: begin
                t = 4'b1100;
                wdata = {in[0+:16], {16{1'b0}}};
            end
            default: t = 4'bxxxx;
            endcase
        end
        `C_MEMSTORE_WORD: begin
            t = 4'b1111;
            wdata = in;
        end
        default: begin 
            t = 4'b1111;
            wdata = in;
        end
        endcase
    end

endmodule
