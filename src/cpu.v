`include "params.vh"
module cpu #(
    parameter filename = ""
) (
    input clk,
    input reset,
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    output [3:0] mem_wstrb,
    input [31:0] mem_rdata,
    output mem_valid,
    input mem_ready
);
    wire [31:0] pc;
    wire [31:0] instruction;
    wire [4:0] reg_waddr, reg_raddr1, reg_raddr2;
    wire [2:0] funct3;
    wire [31:0] reg_rdata1, reg_rdata2;
    wire [31:0] imm;
    wire [11:0] csr_addr;
    wire reg_write;
    wire alusel;
    wire [3:0] reg_wdatasel;
    wire [3:0] pcsel;
    wire uncondjump;
    wire condbranch;
    wire csr_we;
    reg csr_we_pipe;
    wire [31:0] csr_rdata;
    wire [31:0] alu_out;
    reg alusel_pipe;
    reg [3:0] reg_wdatasel_pipe;
    reg [3:0] pcsel_pipe;
    wire [31:0] mtvec, mepc;
    reg [31:0] reg_rdata1_pipe;
    reg [31:0] reg_rdata2_pipe;
    reg reg_write_pipe;
    reg [2:0] funct3_pipe;
    reg [4:0] reg_waddr_pipe;
    reg [31:0] imm_pipe;
    reg [11:0] csr_addr_pipe;
    reg [31:0] pc_pipe;
    reg condbranch_pipe, uncondjump_pipe;
    wire jump_en;
    wire [31:0] reg_rdata1_forward;
    wire [31:0] reg_rdata2_forward;
    wire neg, sra;
    reg neg_pipe, sra_pipe;
    wire memwrite;
    reg memwrite_pipe;
    wire memvalid;
    reg memvalid_pipe;
    wire [2:0] load_op;
    reg [2:0] load_op_pipe;
    wire [31:0] loaddata;
    wire [2:0] store_op;
    reg [2:0] store_op_pipe;
    reg [4:0] reg_raddr1_pipe;
    reg [4:0] reg_raddr2_pipe;
    wire compare_out;
    wire [2:0] aluop = funct3_pipe;
    reg [31:0] reg_wdata;
    reg [31:0] jump_address;
    reg [31:0] pc_fetdec;
    wire except_en;
    reg except_en_pipe;
    wire [3:0] except_op;
    reg [3:0] except_op_pipe;
    wire pipeflush = jump_en;
    wire stall = mem_valid & ~mem_ready;
    reg [31:0] inst_storage, inst_skid;
    reg stall_buf;
    wire [31:0] alu_in2;

    programcounter programcounter_i (
        .clk (clk),
        .reset (reset),
        .stall (stall),
        .jump_address (jump_address),
        .jump_en (jump_en),
        .pc (pc)
    );

    program_rom #(
        .filename (filename)
    ) program_rom (
        .clk (clk),
        .address (pc),
        .data (instruction)
    );

    always @(posedge clk) begin
        stall_buf <= stall;
        if (stall & ~stall_buf)
            inst_storage <= instruction;
    end
    always @* begin
        if (stall_buf)
            inst_skid = inst_storage;
        else
            inst_skid = instruction;
    end

    always @(posedge clk) begin
        if (reset)
            pc_fetdec <= 0;
        else if (~stall)
            pc_fetdec <= pc;
    end
    
    decode decode_i (
        .instruction (inst_skid),
        .reg_raddr1 (reg_raddr1),
        .reg_raddr2 (reg_raddr2),
        .reg_waddr (reg_waddr),
        .reg_write (reg_write),
        .funct3 (funct3),
        .imm (imm),
        .csr_addr (csr_addr),
        .csr_we (csr_we),
        .except_op (except_op),
        .except_en (except_en),
        .neg (neg),
        .sra (sra),
        .alusel (alusel),
        .reg_wdatasel (reg_wdatasel),
        .pcsel (pcsel),
        .uncondjump (uncondjump),
        .condbranch (condbranch),
        .memwrite (memwrite),
        .memvalid (memvalid),
        .load_op (load_op),
        .store_op (store_op)
    );

    registerfile registerfile_i (
        .clk (clk),
        .reset (reset),
        .stall (stall),
        .readaddr1 (reg_raddr1),
        .readdata1 (reg_rdata1),
        .readaddr2 (reg_raddr2),
        .readdata2 (reg_rdata2),
        .writeaddr (reg_waddr_pipe),
        .writedata (reg_wdata),
        .write (reg_write_pipe)
    );

    // Decode/Execute Pipeline Register
    always @(posedge clk) begin
        if (reset) begin
            reg_raddr1_pipe <= 0;
            reg_raddr2_pipe <= 0;
            reg_rdata1_pipe <= 0;
            reg_rdata2_pipe <= 0;
            reg_write_pipe <= 1'b0;
            funct3_pipe <= 3'd0;
            reg_waddr_pipe <= 5'd0;
            imm_pipe <= 0;
            csr_addr_pipe <= 0;
            condbranch_pipe <= 0;
            uncondjump_pipe <= 0;
            pc_pipe <= 0;
            neg_pipe <= 0;
            sra_pipe <= 0;
            alusel_pipe <= 0;
            reg_wdatasel_pipe <= 0;
            pcsel_pipe <= 0;
            csr_we_pipe <= 0;
            memwrite_pipe <= 0;
            memvalid_pipe <= 0;
            load_op_pipe <= 0;
            store_op_pipe <= 0;
            except_op_pipe <= 0;
            except_en_pipe <= 0;
        end
        else if (~stall) begin
            reg_raddr1_pipe <= reg_raddr1;
            reg_raddr2_pipe <= reg_raddr2;
            reg_rdata1_pipe <= reg_rdata1;
            reg_rdata2_pipe <= reg_rdata2;
            reg_write_pipe <= reg_write & ~pipeflush;
            funct3_pipe <= funct3;
            reg_waddr_pipe <= reg_waddr;
            imm_pipe <= imm;
            csr_addr_pipe <= csr_addr;
            condbranch_pipe <= condbranch & ~pipeflush;
            uncondjump_pipe <= uncondjump & ~pipeflush;
            pc_pipe <= pc_fetdec;
            neg_pipe <= neg;
            sra_pipe <= sra;
            alusel_pipe <= alusel;
            reg_wdatasel_pipe <= reg_wdatasel;
            pcsel_pipe <= pcsel;
            csr_we_pipe <= csr_we & ~pipeflush;
            memwrite_pipe <= memwrite & ~pipeflush;
            memvalid_pipe <= memvalid & ~pipeflush;
            load_op_pipe <= load_op;
            store_op_pipe <= store_op;
            except_op_pipe <= except_op;
            except_en_pipe <= except_en;
        end
    end

    // Execute Stage
    assign mem_addr = reg_rdata1_forward + imm_pipe;
    assign mem_valid = memvalid_pipe;

    load load_i (
        .address (mem_addr),
        .rdata (mem_rdata),
        .out (loaddata),
        .op (load_op_pipe)
    );

    store store_i (
        .address (mem_addr),
        .in (reg_rdata2_forward),
        .op (store_op_pipe),
        .we (memwrite_pipe),
        .wdata (mem_wdata),
        .wstrb (mem_wstrb)
    );

    compare compare_i (
        .in1 (reg_rdata1_forward),
        .in2 (reg_rdata2_forward),
        .op (funct3_pipe),
        .out (compare_out)
    );

    assign jump_en = (compare_out & condbranch_pipe) | uncondjump_pipe;

    alu alu_i (
        .in1 (reg_rdata1_forward),
        .in2 (alu_in2),
        .op (aluop),
        .neg (neg_pipe),
        .sra (sra_pipe),
        .out (alu_out)
    );

    csrs csrs_i (
        .clk (clk),
        .reset (reset),
        .stall (stall),
        .reg_rdata1 (reg_rdata1_forward),
        .imm (imm_pipe),
        .csr_addr (csr_addr_pipe),
        .csr_rdata (csr_rdata),
        .csr_op (funct3_pipe),
        .csr_we (csr_we_pipe),
        .pc (pc_pipe),
        .except_op (except_op_pipe),
        .except_en (except_en_pipe),
        .mtvec (mtvec),
        .mepc (mepc)
    );

    assign alu_in2 = (alusel_pipe) ? imm_pipe : reg_rdata2_forward;

    always @* begin
        case (reg_wdatasel_pipe)
        `C_REGWRITEDATASEL_ALU:
            reg_wdata = alu_out;
        `C_REGWRITEDATASEL_IMM:
            reg_wdata = imm_pipe;
        `C_REGWRITEDATASEL_PCIMM:
            reg_wdata = pc_pipe + imm_pipe;
        `C_REGWRITEDATASEL_PC4:
            reg_wdata = pc_pipe + 4;
        `C_REGWRITEDATASEL_CSR:
            reg_wdata = csr_rdata;
        `C_REGWRITEDATASEL_MEM:
            reg_wdata = loaddata;
        default:
            reg_wdata = 32'hxxxxxxxx;
        endcase
    end

    always @* begin
        case (pcsel_pipe)
        `C_PCSEL_PCIMM:
            jump_address = pc_pipe + imm_pipe;
        `C_PCSEL_XRS1IMM:
            jump_address = reg_rdata1_forward + imm_pipe;
        `C_PCSEL_MTVEC:
            jump_address = mtvec;
        `C_PCSEL_MEPC:
            jump_address = mepc;
        default:
            jump_address = 32'hxxxxxxxx;
        endcase
    end

    forward forward_i (
        .clk (clk),
        .reset (reset),
        .stall (stall),
        .reg_waddr (reg_waddr_pipe),
        .reg_wdata (reg_wdata),
        .reg_write (reg_write_pipe),
        .reg_raddr1 (reg_raddr1_pipe),
        .reg_rdata1 (reg_rdata1_pipe),
        .reg_raddr2 (reg_raddr2_pipe),
        .reg_rdata2 (reg_rdata2_pipe),
        .reg_rdata1_forward (reg_rdata1_forward),
        .reg_rdata2_forward (reg_rdata2_forward)
    );

endmodule
