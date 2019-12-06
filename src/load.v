`include "params.vh"
module load (
    input [31:0] address,
    input [31:0] rdata,
    output reg [31:0] out,
    input [2:0] op 
);
    always @* begin
        case (op)
        `C_MEMLOAD_BYTE_U: begin
            case (address[1:0])
            0: out = {{24{1'b0}}, rdata[0+:8]};
            1: out = {{24{1'b0}}, rdata[8+:8]};
            2: out = {{24{1'b0}}, rdata[16+:8]};
            3: out = {{24{1'b0}}, rdata[24+:8]};
            default: out = {{24{1'b0}}, rdata[0+:8]};
            endcase
        end
        `C_MEMLOAD_BYTE_S: begin
            case (address[1:0])
            0: out = {{24{rdata[8-1]}}, rdata[0+:8]};
            1: out = {{24{rdata[16-1]}}, rdata[8+:8]};
            2: out = {{24{rdata[24-1]}}, rdata[16+:8]};
            3: out = {{24{rdata[32-1]}}, rdata[24+:8]};
            default: out = {{24{rdata[8-1]}}, rdata[0+:8]};
            endcase
        end
        `C_MEMLOAD_HALF_U: begin
            case (address[1])
            0: out = {{16{1'b0}}, rdata[0+:16]};
            1: out = {{16{1'b0}}, rdata[16+:16]};
            default: out = {{16{1'b0}}, rdata[0+:16]};
            endcase
        end
        `C_MEMLOAD_HALF_S: begin
            case (address[1])
            0: out = {{16{rdata[16-1]}}, rdata[0+:16]};
            1: out = {{16{rdata[32-1]}}, rdata[16+:16]};
            default: out = {{16{rdata[16-1]}}, rdata[0+:16]};
            endcase
        end
        `C_MEMLOAD_WORD: out = rdata;
        default: out = rdata;
        endcase
    end
    
endmodule
