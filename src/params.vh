`define C_ALU_ADD 3'd0
`define C_ALU_SLL 3'd1
`define C_ALU_SLT 3'd2
`define C_ALU_SLTU 3'd3
`define C_ALU_XOR 3'd4
`define C_ALU_SRL 3'd5
`define C_ALU_OR 3'd6
`define C_ALU_AND 3'd7
`define C_ALUINSEL_REG 0
`define C_ALUINSEL_IMM 1
`define C_REGWRITEDATASEL_ALU 0
`define C_REGWRITEDATASEL_IMM 1
`define C_REGWRITEDATASEL_PCIMM 2
`define C_REGWRITEDATASEL_PC4 3
`define C_REGWRITEDATASEL_CSR 4
`define C_REGWRITEDATASEL_MEM 5
`define C_PCSEL_PCIMM 0
`define C_PCSEL_XRS1IMM 1
`define C_PCSEL_MTVEC 2
`define C_PCSEL_MEPC 3
`define C_MEMLOAD_BYTE_S 0
`define C_MEMLOAD_HALF_S 1
`define C_MEMLOAD_WORD 2
`define C_MEMLOAD_BYTE_U 3
`define C_MEMLOAD_HALF_U 4
`define C_MEMSTORE_BYTE 0
`define C_MEMSTORE_HALF 1
`define C_MEMSTORE_WORD 2
`define C_EXCEPTOP_NOP 0
`define C_EXCEPTOP_ECALL 1
`define C_EXCEPTOP_EBREAK 2
`define C_EXCEPTOP_MRET 3
`define CSR_ADDR_MVENDORID 12'hF11
`define CSR_ADDR_MARCHID 12'hF12
`define CSR_ADDR_MIMPID 12'hF13
`define CSR_ADDR_MHARTID 12'hF14
`define CSR_ADDR_MSTATUS 12'h300
`define CSR_ADDR_MISA 12'h301
`define CSR_ADDR_MEDELEG 12'h302
`define CSR_ADDR_MIDELEG 12'h303
`define CSR_ADDR_MIE 12'h304
`define CSR_ADDR_MTVEC 12'h305
`define CSR_ADDR_MCOUNTEREN 12'h306
`define CSR_ADDR_MEPC 12'h341
`define CSR_ADDR_MCAUSE 12'h342
`define CSR_ADDR_MTVAL 12'h343
`define CSR_ADDR_MIP 12'h344
`define EXCEPT_CODE_ILLEGAL_INST 32'h00000002
`define EXCEPT_CODE_BREAKPOINT 32'h00000003
`define EXCEPT_CODE_ECALL_FROM_M 32'h0000000b