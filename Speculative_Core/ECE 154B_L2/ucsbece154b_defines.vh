// ucsbece154b_defines.vh
// ECE 154B, RISC-V pipelined processor 
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


// Misc
localparam   [31:0] pc_start = 32'h00010000;

// ***** FETCH STAGE ****
// Mux to feed PC for mispredicts
localparam          MuxPCnew_fromFetch    = 1'b0;    // NEW PARAMETER
localparam          MuxPCnew_fromExecute  = 1'b1;    // NEW PARAMETER
  
// Mux to choose between PC+4 or BTB
localparam          MuxPCtarget_fromPCPlus4   = 1'b0;   // NEW PARAMETER
localparam          MuxPCtarget_fromBTB       = 1'b1;   // NEW PARAMETER


// **** DECODE STAGE ****
// Control unit (instruction Funct3 codes)
localparam    [2:0] instr_addsub_funct3 = 3'b000; 
localparam    [2:0] instr_slt_funct3    = 3'b010;  
localparam    [2:0] instr_or_funct3     = 3'b110;  
localparam    [2:0] instr_and_funct3    = 3'b111; 
 
localparam    [2:0] instr_beq_funct3    = 3'b000;   // NEW PARAMETER 
localparam    [2:0] instr_bne_funct3    = 3'b001;   // NEW PARAMETER 

// Control unit (instruction Op codes)
localparam    [6:0] instr_Rtype_op    = 7'b0110011;
localparam    [6:0] instr_lw_op       = 7'b0000011;
localparam    [6:0] instr_sw_op       = 7'b0100011;
localparam    [6:0] instr_jal_op      = 7'b1101111;
localparam    [6:0] instr_branch_op   = 7'b1100011;   // CHANGED PARAMETER NAME
localparam    [6:0] instr_ItypeALU_op = 7'b0010011;
localparam    [6:0] instr_lui_op      = 7'b0110111;
localparam    [6:0] instr_jalr_op     = 7'b1100111;


// Control unit (ALU op codes)
localparam    [1:0] ALUop_mem    = 2'b00;
localparam    [1:0] ALUop_beqbne = 2'b01;  // CHANGED PARAMETER NAME
localparam    [1:0] ALUop_other  = 2'b10;

// Extend Unit (ImmSrc codes)
localparam    [2:0] imm_Itype = 3'b000;
localparam    [2:0] imm_Stype = 3'b001;
localparam    [2:0] imm_Btype = 3'b010;
localparam    [2:0] imm_Jtype = 3'b011;
localparam    [2:0] imm_Utype = 3'b100;


// **** EXECUTE STAGE ****
// ALU (ALUControl codes)
localparam    [2:0] ALUcontrol_add = 3'b000;
localparam    [2:0] ALUcontrol_sub = 3'b001;
localparam    [2:0] ALUcontrol_and = 3'b010;
localparam    [2:0] ALUcontrol_or  = 3'b011;
localparam    [2:0] ALUcontrol_slt = 3'b101;

// Mux (Forwarding inputs to ALU)
localparam    [1:0] forward_ex    = 2'b00;
localparam    [1:0] forward_wb    = 2'b01;
localparam    [1:0] forward_mem   = 2'b10;

// Mux (Feeding ALU SrcB input) 
localparam     SrcB_reg  = 1'b0;
localparam     SrcB_imm  = 1'b1;


// **** MEMORY STAGE ****


// **** WRITEBACK STAGE ****
// Mux (supplying ResultW) 
localparam    [1:0] MuxResult_aluout  = 2'b00;
localparam    [1:0] MuxResult_mem     = 2'b01;
localparam    [1:0] MuxResult_PCPlus4 = 2'b10;
localparam    [1:0] MuxResult_imm     = 2'b11;




