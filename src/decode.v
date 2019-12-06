`include "params.vh"
module decode (
    input [31:0] instruction,
    output [4:0] reg_raddr1,
    output [4:0] reg_raddr2,
    output [4:0] reg_waddr,
    output reg reg_write,
    output [2:0] funct3,
    output reg [31:0] imm,
    output [11:0] csr_addr,
    output reg csr_we,
    output reg [3:0] except_op,
    output reg except_en,
    output neg,
    output sra,
    output reg alusel,
    output reg [3:0] reg_wdatasel,
    output reg [3:0] pcsel,
    output reg uncondjump,
    output reg condbranch,
    output memwrite,
    output memvalid,
    output reg [2:0] load_op,
    output reg [2:0] store_op
);
    wire [6:0] opcode = instruction[0+:7];
    wire [5:0] funct7 = instruction[25+:6];
    assign reg_waddr = instruction[7+:5];
    assign reg_raddr1 = instruction[15+:5];
    assign reg_raddr2 = instruction[20+:5];
    assign funct3 = instruction[12+:3];
    assign csr_addr = instruction[20+:12];
    assign memwrite = (opcode == 7'h23);
    assign memvalid = (opcode == 7'h03) | (opcode == 7'h23);
    wire [31:0] immi = {{20{instruction[31]}}, instruction[20+:12]};
    wire [31:0] imms = {{20{instruction[31]}}, instruction[25+:7], instruction[7+:5]};
    wire [31:0] immu = {instruction[12+:20], {12{1'b0}}};
    wire [31:0] immb = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[25+:6], instruction[8+:4], 1'b0};
    wire [31:0] immj = {{11{instruction[31]}}, instruction[31], instruction[12+:8], instruction[20], instruction[21+:10], 1'b0};
    assign neg = (opcode == 7'h33) & (|funct7);
    assign sra = (|funct7);

    always @* begin
        case (opcode)
        7'h37: begin  // lui: x[rd] = sext(imm[31:12] << 12)
            imm = immu;
            reg_write = 1;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_IMM;  // imm
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        7'h17: begin  // auipc: x[rd] = pc + sext(imm[31:12] << 12)
            imm = immu;
            reg_write = 1;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_PCIMM;  // pc+imm
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        7'h6f: begin  // jal: x[rd] = pc+4; pc += sext(offset)
            imm = immj;
            reg_write = 1;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_PC4;  // pc+4
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 1;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        7'h67: begin  // jalr: t=pc+4; pc=(x[rs1]+sext(offset))&~1; x[rd]=t
            imm = immi;
            reg_write = 1;
            alusel = `C_ALUINSEL_IMM;
            reg_wdatasel = `C_REGWRITEDATASEL_PC4;
            pcsel = `C_PCSEL_XRS1IMM;
            uncondjump = 1;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        7'h63: begin // branch (beq, bne, ...)
            imm = immb;
            reg_write = 0;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_ALU;
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 1;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        7'h03: begin // load data (lb, lh, ...)
            imm = immi;
            reg_write = 1;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_MEM;
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            case (funct3)
            0: load_op = `C_MEMLOAD_BYTE_S;
            1: load_op = `C_MEMLOAD_HALF_S;
            2: load_op = `C_MEMLOAD_WORD;
            4: load_op = `C_MEMLOAD_BYTE_U;
            5: load_op = `C_MEMLOAD_HALF_U;
            default: load_op = `C_MEMLOAD_WORD;
            endcase
            store_op = `C_MEMSTORE_WORD;
        end
        7'h23: begin  // store data (sb, sh, ...)
            imm = imms;
            reg_write = 0;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_ALU;
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            case (funct3)
            0: store_op = `C_MEMSTORE_BYTE;
            1: store_op = `C_MEMSTORE_HALF;
            2: store_op = `C_MEMSTORE_WORD;
            default: store_op = `C_MEMSTORE_WORD;
            endcase
            load_op = `C_MEMLOAD_WORD;
        end
        7'h13: begin  // imm
            imm = immi;
            reg_write = 1;
            alusel = `C_ALUINSEL_IMM;
            reg_wdatasel = `C_REGWRITEDATASEL_ALU;
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        7'h33: begin  // add, sub, sll, slt, sltu, xor, srl, sra, or, and
            imm = immb;
            reg_write = 1;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_ALU;
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        7'h0f: begin  // fence, fence.i
            imm = immi;
            reg_write = 0;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_ALU;
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        7'h73: begin  // csr operate
            if (funct3 == 0) begin
                reg_write = 0;
                uncondjump = 1;
                reg_wdatasel = `C_REGWRITEDATASEL_ALU;
                if (csr_addr == 12'h000) begin // ecall
                    csr_we = 0;
                    except_op = `C_EXCEPTOP_ECALL;
                    except_en = 1;
                    pcsel = `C_PCSEL_MTVEC;
                end
                else if (csr_addr == 12'h001) begin // ebreak
                    csr_we = 0;
                    except_op = `C_EXCEPTOP_EBREAK;
                    except_en = 1;
                    pcsel = `C_PCSEL_MTVEC;
                end
                else if (csr_addr == 12'h302) begin // mret
                    csr_we = 0;
                    except_op = `C_EXCEPTOP_MRET;
                    except_en = 1;
                    pcsel = `C_PCSEL_MEPC;
                end
                else begin  // others
                    csr_we = 0;
                    except_op = 0;
                    except_en = 0;
                    pcsel = `C_PCSEL_MEPC;
                end
            end
            else begin
                reg_write = 1;
                uncondjump = 0;
                csr_we = 1;
                except_op = `C_EXCEPTOP_NOP;
                except_en = 0;
                reg_wdatasel = `C_REGWRITEDATASEL_CSR;
                pcsel = `C_PCSEL_PCIMM;
            end
            imm = immi;
            alusel = `C_ALUINSEL_REG;
            condbranch = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        default: begin
            imm = 0;
            reg_write = 0;
            alusel = `C_ALUINSEL_REG;
            reg_wdatasel = `C_REGWRITEDATASEL_ALU;
            pcsel = `C_PCSEL_PCIMM;
            uncondjump = 0;
            condbranch = 0;
            csr_we = 0;
            except_op = `C_EXCEPTOP_NOP;
            except_en = 0;
            load_op = `C_MEMLOAD_WORD;
            store_op = `C_MEMSTORE_WORD;
        end
        endcase
    end

endmodule
