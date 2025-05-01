// ucsbece154b_controller.v
// ECE 154B, RISC-V pipelined processor 
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited

module ucsbece154b_controller (
    input                clk, reset,
    input         [6:0]  op_i, 
    input         [2:0]  funct3_i,
    input                funct7b5_i,
    input 	         ZeroE_i,
    input         [4:0]  Rs1D_i,
    input         [4:0]  Rs2D_i,
    input         [4:0]  Rs1E_i,
    input         [4:0]  Rs2E_i,
    input         [4:0]  RdE_i,
    input         [4:0]  RdM_i,
    input         [4:0]  RdW_i,
    output wire		 StallF_o,  
    output wire          StallD_o,
    output wire          FlushD_o,
    output wire    [2:0] ImmSrcD_o,
    output wire          PCSrcE_o,
    output wire          FlushE_o,
    output reg     [2:0] ALUControlE_o,
    output reg           ALUSrcE_o,
    output reg     [1:0] ForwardAE_o,
    output reg     [1:0] ForwardBE_o,
    output reg           MemWriteM_o,
    output reg          RegWriteW_o,
    output reg    [1:0] ResultSrcW_o, 
    output reg    [1:0] ResultSrcM_o
);
 `include "ucsbece154b_defines.vh"

reg RegWriteD,RegWriteE,RegWriteM;
reg [1:0] ResultSrcD, ResultSrcE;
reg MemWriteD, MemWriteE;
reg JumpD, JumpE;
reg BranchD, BranchE;
reg [2:0] ALUControlD;
reg ALUSrcD;
reg [2:0] ImmSrcD;
wire [1:0] ForwardAE_local, ForwardBE_local;

// Reset Signalling
always @(posedge reset) begin
	RegWriteD <= 'b0; RegWriteE <= 'b0; RegWriteM <= 'b0; RegWriteW_o <= 'b0;
	ResultSrcD <= 'b0; ResultSrcE <= 'b0; ResultSrcW_o <= 'b0; ResultSrcM_o <= 'b0;
	MemWriteD <= 'b0 ; MemWriteE <= 'b0; MemWriteM_o <= 'b0;
	JumpD <= 'b0 ; JumpE <= 'b0;
	BranchD <= 'b0 ; BranchE <= 'b0;
	ALUControlD <= 'b0 ; ALUControlE_o <= 'b0;
	ALUSrcD <= 'b0; ALUSrcE_o <= 'b0;
	ForwardAE_o <= 'b0; ForwardBE_o <= 'b0; 
end

// Pipelining all necessary signals
always @(posedge clk) begin
	RegWriteE <= RegWriteD;
	RegWriteM <= RegWriteE;
	RegWriteW_o <= RegWriteM;

	ResultSrcE <= ResultSrcD;
	ResultSrcM_o <= ResultSrcE;
	ResultSrcW_o <= ResultSrcM_o;

	MemWriteE <= MemWriteD;
	MemWriteM_o <= MemWriteE;

	JumpE <= JumpD;
	BranchE <= BranchD;
	ALUControlE_o <= ALUControlD;
	ALUSrcE_o <= ALUSrcD;

        //ForwardAE_o  = ForwardAE_local;
        //ForwardBE_o  = ForwardBE_local;
end

// Designing the main control unit
assign PCSrcE_o = ( BranchE & ZeroE_i ) | JumpE;
assign ImmSrcD_o = ImmSrcD;

  always @(*) begin
    case (op_i)
      instr_Rtype_op: begin	// add, sub, and, or, slt 
          RegWriteD = 'b1;
          ResultSrcD = MuxResult_aluout;      
          MemWriteD = 'b0;
          JumpD = 'b0;      
          BranchD = 'b0;
          ALUSrcD = SrcB_reg;
          ImmSrcD = imm_Itype;      
	  case (funct3_i)
	    instr_addsub_funct3: begin
	    	case (funct7b5_i) 
		  1'b0: begin ALUControlD = ALUcontrol_add; end
		  1'b1: begin ALUControlD = ALUcontrol_sub; end
		endcase
	    end
	    instr_and_funct3: begin ALUControlD = ALUcontrol_and; end
	    instr_or_funct3: begin ALUControlD = ALUcontrol_or; end
	    instr_slt_funct3: begin ALUControlD = ALUcontrol_slt; end
	    default: begin end
	  endcase      
      end

      instr_lw_op: begin	//  lw
          RegWriteD = 'b1;
          ResultSrcD = MuxResult_mem;      
          MemWriteD = 'b0;
          JumpD = 'b0;      
          BranchD = 'b0;
          ALUControlD = ALUcontrol_add;      
          ALUSrcD = SrcB_imm;
          ImmSrcD = imm_Itype;      
      end

      instr_sw_op: begin	//  sw
          RegWriteD = 'b0;
          //ResultSrcD = 'z;      
          MemWriteD = 'b1;
          JumpD = 'b0;      
          BranchD = 'b0;
          ALUControlD = ALUcontrol_add;      
          ALUSrcD = SrcB_imm;
          ImmSrcD = imm_Stype;      
      end

      instr_jal_op: begin	//  jal
          RegWriteD = 'b1;
          ResultSrcD = MuxResult_PCPlus4;      
          MemWriteD = 'b0;
          JumpD = 'b1;      
          BranchD = 'b0;
          ALUControlD = ALUcontrol_add;      
          //ALUSrcD = 'z;
          ImmSrcD = imm_Jtype;      
      end

      instr_beq_op: begin	//  beq
          RegWriteD = 'b0;
          //ResultSrcD = 'z;      
          MemWriteD = 'b0;
          JumpD = 'b0;      
          BranchD = 'b1;
          ALUControlD = ALUcontrol_sub;      
          ALUSrcD = SrcB_reg;
          ImmSrcD = imm_Btype;      
      end

      instr_ItypeALU_op: begin	//  addi, andi, ori, slti
	  RegWriteD = 'b1;
	  ResultSrcD = MuxResult_aluout;
	  MemWriteD = 'b0;
	  JumpD = 'b0;
	  BranchD = 'b0;
	  ALUSrcD = SrcB_imm;
	  ImmSrcD = imm_Itype;
	  case (funct3_i)
	    instr_addsub_funct3: begin ALUControlD = ALUcontrol_add; end
	    instr_and_funct3: begin ALUControlD = ALUcontrol_and; end
	    instr_or_funct3: begin ALUControlD = ALUcontrol_or; end
	    instr_slt_funct3: begin ALUControlD = ALUcontrol_slt; end
	    default: begin end
	  endcase
      end

      instr_lui_op: begin	//  lui
          RegWriteD = 'b1;
          ResultSrcD = MuxResult_imm;      
          MemWriteD = 'b0;
          JumpD = 'b0;      
          BranchD = 'b0;
          ALUControlD = ALUcontrol_add;      
          //ALUSrcD = 'z;
          ImmSrcD = imm_Utype;      
      end

      default: begin
        // Leave control signals at their default safe values
      end
    endcase
  end


// Hazard Unit Implementation
/*
// Interfacing with the hazard unit
ucsbece154b_hazard_unit hazard_unit (
    .ResultSrcEb0_i(ResultSrcE[0]), 
    .RegWriteM_i(RegWriteM),
    .Rs1E_i(Rs1E_i),
    .Rs2E_i(Rs2E_i),
    .RdE_i(RdE_i),
    .Rs1D_i(Rs1D_i),
    .Rs2D_i(Rs2D_i),
    .RdM_i(RdM_i),
    .RdW_i(RdW_i),
    .RegWriteW_i(RegWriteW_o),
    .PCSrcE_i(PCSrcE_o),
    .StallF_o(StallF_o),
    .StallD_o(StallD_o),
    .FlushD_o(FlushD_o),
    .FlushE_o(FlushE_o),
    .ForwardAE_o(ForwardAE_local),
    .ForwardBE_o(ForwardBE_local)
);
*/
always @(*) begin
    ForwardAE_o = forward_ex;
    ForwardBE_o = forward_ex;
    
    // ForwardAE_o logic
    if ((Rs1E_i == RdW_i) && (RegWriteW_o) && (RdW_i != 0)) begin
        ForwardAE_o = forward_wb;
    end else if ((Rs1E_i == RdM_i) && (RegWriteM) && (RdM_i != 0)) begin
        ForwardAE_o = forward_mem;
    end

    // ForwardBE_o logic
    if ((Rs2E_i == RdW_i) && (RegWriteW_o) && (RdW_i != 0)) begin
        ForwardBE_o = forward_wb;
    end else if ((Rs2E_i == RdM_i) && (RegWriteM) && (RdM_i != 0)) begin
        ForwardBE_o = forward_mem;
    end
end

    wire lwStall;
    assign lwStall = ( 
                        ( (ResultSrcE[0]) & (((RdE_i == Rs1D_i) | (RdE_i == Rs2D_i)) & (RdE_i != 0)) ) |  // (Mem_Write == 1) & ( RdE == (Rs1D or Rs2D) != 0) 
                        ( (RegWriteW_o) & (((Rs1D_i == RdW_i)|(Rs2D_i == RdW_i)) & (RdW_i != 0)) )        // (RegWrite == 1) & (RdW == (Rs1D or Rs2D) != 0)       
                     );
    assign StallF_o = lwStall;
    assign StallD_o = lwStall;
    assign FlushE_o = lwStall | PCSrcE_o;
    assign FlushD_o = PCSrcE_o;

endmodule
