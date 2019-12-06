`include "params.vh"
module csrs (
    input clk,
    input reset,
    input stall,
    input [31:0] reg_rdata1,
    input [31:0] imm,
    input [11:0] csr_addr,
    output reg [31:0] csr_rdata,
    input [2:0] csr_op,
    input csr_we,
    input [31:0] pc,
    input [3:0] except_op,
    input except_en,
    output [31:0] mtvec,
    output [31:0] mepc
);
    reg [31:0] mvendorid_reg;
    reg [31:0] marchid_reg;
    reg [31:0] mimpid_reg;
    reg [31:0] mhartid_reg;
    reg [31:0] mstatus_reg;
    reg [31:0] misa_reg;
    reg [31:0] medeleg_reg;
    reg [31:0] mideleg_reg;
    reg [31:0] mie_reg;
    reg [31:0] mtvec_reg;
    reg [31:0] mcounteren_reg;
    reg [31:0] mepc_reg;
    reg [31:0] mcause_reg;
    reg [31:0] mtval_reg;
    reg [31:0] mip_reg;
    reg [31:0] t;
    wire [31:0] zimm = {{27{1'b0}}, imm[4:0]};

    always @* begin
        case (csr_op)
        1: t = reg_rdata1;
        2: t = csr_rdata | reg_rdata1;
        3: t = csr_rdata & ~reg_rdata1;
        5: t = zimm;
        6: t = csr_rdata | zimm;
        7: t = csr_rdata & ~zimm;
        default: t = reg_rdata1;
        endcase
    end

    assign mtvec = mtvec_reg;
    assign mepc = mepc_reg;

    always @(posedge clk) begin
        if (reset) begin
            mvendorid_reg <= 0;
            marchid_reg <= 0;
            mimpid_reg <= 0;
            mhartid_reg <= 0;
            mstatus_reg <= 0;
            misa_reg <= 0;
            medeleg_reg <= 0;
            mideleg_reg <= 0;
            mie_reg <= 0;
            mtvec_reg <= 0;
            mcounteren_reg <= 0;
            mepc_reg <= 0;
            mcause_reg <= 0;
            mtval_reg <= 0;
            mip_reg <= 0;
        end
        else if (~stall) begin
            if (except_en) begin
                mepc_reg <= pc;
                case (except_op)
                `C_EXCEPTOP_ECALL:
                    mcause_reg <= `EXCEPT_CODE_ECALL_FROM_M;
                `C_EXCEPTOP_EBREAK:
                    mcause_reg <= `EXCEPT_CODE_BREAKPOINT;
                default:
                    mcause_reg <= 0;
                endcase
            end
            else if (csr_we) begin
                case (csr_addr)
                `CSR_ADDR_MVENDORID  : mvendorid_reg <= t;
                `CSR_ADDR_MARCHID    : marchid_reg <= t;
                `CSR_ADDR_MIMPID     : mimpid_reg <= t;
                `CSR_ADDR_MHARTID    : mhartid_reg <= t;
                `CSR_ADDR_MSTATUS    : mstatus_reg <= t;
                `CSR_ADDR_MISA       : misa_reg <= t;
                `CSR_ADDR_MEDELEG    : medeleg_reg <= t;
                `CSR_ADDR_MIDELEG    : mideleg_reg <= t;
                `CSR_ADDR_MIE        : mie_reg <= t;
                `CSR_ADDR_MTVEC      : mtvec_reg <= t;
                `CSR_ADDR_MCOUNTEREN : mcounteren_reg <= t;
                `CSR_ADDR_MEPC       : mepc_reg <= t;
                `CSR_ADDR_MCAUSE     : mcause_reg <= t;
                `CSR_ADDR_MTVAL      : mtval_reg <= t;
                `CSR_ADDR_MIP        : mip_reg <= t;
                default             : ;
                endcase
            end
        end
    end

    always @* begin
        case (csr_addr)
        `CSR_ADDR_MVENDORID  : csr_rdata = mvendorid_reg;
        `CSR_ADDR_MARCHID    : csr_rdata = marchid_reg;
        `CSR_ADDR_MIMPID     : csr_rdata = mimpid_reg;
        `CSR_ADDR_MHARTID    : csr_rdata = mhartid_reg;
        `CSR_ADDR_MSTATUS    : csr_rdata = mstatus_reg;
        `CSR_ADDR_MISA       : csr_rdata = misa_reg;
        `CSR_ADDR_MEDELEG    : csr_rdata = medeleg_reg;
        `CSR_ADDR_MIDELEG    : csr_rdata = mideleg_reg;
        `CSR_ADDR_MIE        : csr_rdata = mie_reg;
        `CSR_ADDR_MTVEC      : csr_rdata = mtvec_reg;
        `CSR_ADDR_MCOUNTEREN : csr_rdata = mcounteren_reg;
        `CSR_ADDR_MEPC       : csr_rdata = mepc_reg;
        `CSR_ADDR_MCAUSE     : csr_rdata = mcause_reg;
        `CSR_ADDR_MTVAL      : csr_rdata = mtval_reg;
        `CSR_ADDR_MIP        : csr_rdata = mip_reg;
        default             : csr_rdata = 0;
        endcase
    end

endmodule
