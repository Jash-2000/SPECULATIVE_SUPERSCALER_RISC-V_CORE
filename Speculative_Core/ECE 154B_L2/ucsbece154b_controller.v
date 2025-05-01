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
    output reg     [2:0] ALUControlE_o,
    output reg           ALUSrcE_o,
    output wire          FlushE_o,
    output reg     [1:0] ForwardAE_o,
    output reg     [1:0] ForwardBE_o,
    output reg           MemWriteM_o,
    output reg          RegWriteW_o,
    output reg    [1:0] ResultSrcW_o, 
    output reg    [1:0] ResultSrcM_o
);


 `include "ucsbece154b_defines.vh"

// Decoder signals other than from hazard unit are implemented next. Hazard unit is implemented at the end

// ***** FETCH STAGE ***************************************

// ***** DECODE STAGE **************************************
 wire RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
 reg BranchTypeD;
 wire [1:0] ResultSrcD; 
 reg [2:0] ALUControlD;
 
 wire [1:0] ALUOpD;

 reg [11:0] maindecoderD; // Note that maindecoder is just clubbing of signals for a convinient (compact, human readable) implementaiton of main decoder table. "reg" is required because is maindecoder is used in always block, which is used because of case statements. Also note that default in always blocks is a must in such case, otherwise maindecoder will be treated as register.


 assign {RegWriteD,	
	ImmSrcD_o,
        ALUSrcD,
        MemWriteD,
        ResultSrcD,
	BranchD, 
	ALUOpD,
	JumpD} = maindecoderD;

 always @ * begin
   case (op_i)
	instr_lw_op:        maindecoderD = 12'b1_000_1_0_01_0_00_0;       
	instr_sw_op:        maindecoderD = 12'b0_001_1_1_00_0_00_0; 
	instr_Rtype_op:     maindecoderD = 12'b1_xxx_0_0_00_0_10_0;  
	instr_branch_op:    maindecoderD = 12'b0_010_0_0_00_1_01_0;  
	instr_ItypeALU_op:  maindecoderD = 12'b1_000_1_0_00_0_10_0; 
	instr_jal_op:       maindecoderD = 12'b1_011_x_0_10_0_xx_1; 
        instr_lui_op:       maindecoderD = 12'b1_100_x_0_11_0_xx_0; 
        instr_jalr_op:      maindecoderD = 12'b1_000_x_0_10_0_xx_1;  
	default: 	    maindecoderD = 12'b0_xxx_x_0_xx_0_xx_0; 
//            `ifdef SIM
//            $warning("Unsupported op given: %h", op_i);
//            `else
//            ;
//            `endif
   endcase
 end

 wire RtypeSubD;

 assign RtypeSubD = funct7b5_i & op_i[5];

 always @ * begin
  case(ALUOpD)
    ALUop_mem:                 ALUControlD = ALUcontrol_add;
    ALUop_beqbne:              ALUControlD = ALUcontrol_sub;
    ALUop_other: 
       case(funct3_i)
           instr_addsub_funct3: 
                 if(RtypeSubD) ALUControlD = ALUcontrol_sub;
                 else          ALUControlD = ALUcontrol_add;  
           instr_slt_funct3:   ALUControlD = ALUcontrol_slt;  
           instr_or_funct3:    ALUControlD = ALUcontrol_or;  
           instr_and_funct3:   ALUControlD = ALUcontrol_and;  
           default:            ALUControlD = 3'bxxx;
        //     `ifdef SIM
        //         $warning("Unsupported funct3 given: %h", funct3_i);
        //     `else
        //         ;
        //     `endif  
       endcase
    default: 
      `ifdef SIM
          $warning("Unsupported ALUop given: %h", ALUOpD);
      `else
          ;
      `endif   
   endcase
 end

// this is pipelined signal to invert zero when branch is bne

 always @ * begin
  case(funct3_i)
    instr_beq_funct3:      BranchTypeD = 1'b0;
    instr_bne_funct3:      BranchTypeD = 1'b1;
    default:               BranchTypeD = 1'bx;
   endcase
 end


// ****** EXECUTE STAGE ****************************************
 reg RegWriteE, MemWriteE, JumpE, BranchE;
 reg BranchTypeE;
 reg [1:0] ResultSrcE;

 assign PCSrcE_o = BranchE & (ZeroE_i ^ BranchTypeE) | JumpE; 

// Update registers (move control signals via pipeline)
 always @(posedge clk) begin
    if(FlushE_o | reset) begin
       RegWriteE     <=  1'b0;
       ResultSrcE    <=  2'b0;
       MemWriteE     <=  1'b0;
       JumpE         <=  1'b0;
       BranchE       <=  1'b0;
       ALUControlE_o <=  3'b0;
       ALUSrcE_o     <=  1'b0;
       BranchTypeE   <=  1'b0;
    end else begin
       RegWriteE     <= RegWriteD;
       ResultSrcE    <= ResultSrcD;
       MemWriteE     <= MemWriteD;
       JumpE         <= JumpD;
       BranchE       <= BranchD;
       ALUControlE_o <= ALUControlD;
       ALUSrcE_o     <= ALUSrcD; 
       BranchTypeE   <= BranchTypeD;
    end
 end 

// ***** MEMORY STAGE ******************************************
 reg RegWriteM;

// Update registers (move control signals via pipeline)
 always @(posedge clk) begin
    if(reset) begin 
       RegWriteM    <= 1'b0;
       ResultSrcM_o <= 2'b0;
       MemWriteM_o  <= 1'b0;
    end else begin
       RegWriteM    <= RegWriteE;
       ResultSrcM_o <= ResultSrcE;
       MemWriteM_o  <= MemWriteE;
    end
  end


// ***** WRITEBACK STAGE ***************************************

// Update registers (move control signals via pipeline)
 always @(posedge clk) begin
    if(reset) begin 
       RegWriteW_o  <= 1'b0;
       ResultSrcW_o <= 2'b0;
    end else begin
       RegWriteW_o  <= RegWriteM;
       ResultSrcW_o <= ResultSrcM_o;
    end
  end


// Hazard unit (stall and data forwarding)

// Forwarding logic
 always @ * begin
  if      ( (Rs1E_i == RdM_i) & RegWriteM & (Rs1E_i != 0) ) 
         ForwardAE_o = forward_mem;
  else if ( (Rs1E_i == RdW_i) & RegWriteW_o & (Rs1E_i != 0) ) 
         ForwardAE_o = forward_wb;
  else   ForwardAE_o = forward_ex;
 end
  
 always @ * begin
  if      ( (Rs2E_i == RdM_i) & RegWriteM & (Rs2E_i != 0) ) 
         ForwardBE_o = forward_mem;
  else if ( (Rs2E_i == RdW_i) & RegWriteW_o & (Rs2E_i != 0) ) 
         ForwardBE_o = forward_wb;
  else   ForwardBE_o = forward_ex;
 end

// Stall logic
 wire lwStall; 

 assign lwStall = (ResultSrcE == 1) & ( (Rs1D_i == RdE_i) | (Rs2D_i == RdE_i) ) & (RdE_i != 0);
 assign StallF_o = lwStall;
 assign StallD_o = lwStall;
 assign FlushD_o = PCSrcE_o;
 assign FlushE_o = lwStall | PCSrcE_o; 
  


endmodule

