// ucsbece154b_datapath.v
// ECE 154B, RISC-V pipelined processor 
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


module ucsbece154b_datapath (
    input                clk, reset,
    input                PCSrcE_i,
    input                StallF_i,
    output reg    [31:0] PCF_o,
    input                StallD_i,
    input                FlushD_i,
    input         [31:0] InstrF_i,
    output wire    [6:0] op_o,
    output wire    [2:0] funct3_o,
    output wire          funct7b5_o,
    input                RegWriteW_i,
    input          [2:0] ImmSrcD_i,
    output wire    [4:0] Rs1D_o,
    output wire    [4:0] Rs2D_o,
    input  wire          FlushE_i,
    output reg     [4:0] Rs1E_o,
    output reg     [4:0] Rs2E_o, 
    output reg     [4:0] RdE_o, 
    input                ALUSrcE_i,
    input          [2:0] ALUControlE_i,
    input          [1:0] ForwardAE_i,
    input          [1:0] ForwardBE_i,
    output               ZeroE_o,
    output reg     [4:0] RdM_o, 
    output reg    [31:0] ALUResultM_o,
    output reg    [31:0] WriteDataM_o,
    input         [31:0] ReadDataM_i,
    input          [1:0] ResultSrcW_i,
    output reg     [4:0] RdW_o,
    input          [1:0] ResultSrcM_i
);

`include "ucsbece154b_defines.vh"

//Pre-Fetch
wire [31:0] ResultW;
wire [31:0] PCF_prime;

//Fetch
wire [31:0] PCPlus4F;

assign PCPlus4F = PCF_o + 'd4;

always @(posedge reset) begin
    PCF_o <= pc_start;
end

always @ (posedge clk) begin
    if (!StallF_i) PCF_o <= PCF_prime;
end

//Fetch End

//Decode
reg [31:0] InstrD;
reg [31:0] PCD;
reg [31:0] PCPlus4D;
wire [4:0] RdD;

always @ (posedge clk) begin
    if (FlushD_i) begin
        InstrD     <= 32'b0;
        PCD        <= 32'b0;
        PCPlus4D   <= 32'b0;
    end else if (!StallD_i) begin
        InstrD     <= InstrF_i;
        PCD        <= PCF_o;
        PCPlus4D   <= PCPlus4F;
    end
end



assign op_o = InstrD[6:0];
assign funct3_o = InstrD[14:12];
assign funct7b5_o = InstrD[30];
assign Rs1D_o = InstrD[19:15];
assign Rs2D_o = InstrD[24:20];
assign RdD = InstrD[11:7];

wire [31:0] RD1D, RD2D;

ucsbece154b_rf rf (
    	.clk(clk),
    	.a1_i(InstrD[19:15]),
	.a2_i(InstrD[24:20]),
	.a3_i(RdW_o),
	.rd1_o(RD1D),
	.rd2_o(RD2D),
	.we3_i(RegWriteW_i),
	.wd3_i(ResultW)
);

wire [31:0] ExtImmD;
assign ExtImmD = (ImmSrcD_i == imm_Itype) ? {{20{InstrD[31]}}, InstrD[31:20]} :
                 (ImmSrcD_i == imm_Stype) ? {{20{InstrD[31]}}, InstrD[31:25], InstrD[11:7]} :
                 (ImmSrcD_i == imm_Btype) ? {{19{InstrD[31]}}, InstrD[31], InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0} :
                 (ImmSrcD_i == imm_Jtype) ? {{11{InstrD[31]}}, InstrD[31], InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0} :
                 (ImmSrcD_i == imm_Utype) ? {InstrD[31:12], 12'b0} :
                 32'bx;
//Decode End

//Execute
reg [31:0] RD1E, RD2E;
reg [31:0] PCE;
reg [31:0] ExtImmE;
reg [31:0] PCPlus4E;
wire [31:0] PCTargetE;
wire [31:0] SrcAE, SrcBE, WriteDataE;

always @ (posedge clk) begin
    if (FlushE_i) begin
        RD1E       <= 32'b0;
        RD2E       <= 32'b0;
        PCE        <= 32'b0;
        Rs1E_o     <= 5'b0;
        Rs2E_o     <= 5'b0;
        RdE_o      <= 5'b0;
        ExtImmE    <= 32'b0;
        PCPlus4E   <= 32'b0;
    end else begin
        RD1E       <= RD1D;
        RD2E       <= RD2D;
        PCE        <= PCD;
        Rs1E_o     <= Rs1D_o;
        Rs2E_o     <= Rs2D_o;
        RdE_o      <= RdD;
        ExtImmE    <= ExtImmD;
        PCPlus4E   <= PCPlus4D;
    end
end


assign SrcAE = (ForwardAE_i == forward_ex) ? RD1E :
	       (ForwardAE_i == forward_wb) ? ResultW:
	       (ForwardAE_i == forward_mem) ? ALUResultM_o:
	       32'bx;

assign WriteDataE = (ForwardBE_i == forward_ex) ? RD2E :
	       	    (ForwardBE_i == forward_wb) ? ResultW:
	            (ForwardBE_i == forward_mem) ? ALUResultM_o:
	 	    32'bx;

assign SrcBE = (ALUSrcE_i == SrcB_reg) ? WriteDataE :
	       (ALUSrcE_i == SrcB_imm) ? ExtImmE:
	       32'bx;

assign PCTargetE = PCE + ExtImmE;

wire [31:0] ALUResultE;

ucsbece154b_alu alu (
	.a_i(SrcAE),
	.b_i(SrcBE),
	.alucontrol_i(ALUControlE_i),
	.result_o(ALUResultE),
	.zero_o(ZeroE_o)
);
//Execute End

//Memory
reg  [31:0] ExtImmM;
reg  [31:0] PCPlus4M;

always @ (posedge clk) begin
        ALUResultM_o <= ALUResultE;
        WriteDataM_o <= WriteDataE;
        RdM_o        <= RdE_o;
        ExtImmM      <= ExtImmE;
        PCPlus4M     <= PCPlus4E;
end
//Memory End

//Writeback and Pre-Fetch
reg [31:0] ALUResultW;
reg [31:0] ReadDataW;
reg [31:0] ExtImmW;
reg [31:0] PCPlus4W;

assign ResultW = (ResultSrcW_i == MuxResult_aluout) ? ALUResultW :
                 (ResultSrcW_i == MuxResult_mem) ? ReadDataW :
                 (ResultSrcW_i == MuxResult_PCPlus4) ? PCPlus4W :
                 (ResultSrcW_i == MuxResult_imm) ? ExtImmW :
                 32'bx;

assign PCF_prime = (PCSrcE_i == MuxPC_PCPlus4) ? PCPlus4F :
	      (PCSrcE_i == MuxPC_PCTarget) ? PCTargetE :
	      32'bx;

always @ (posedge clk) begin
        ALUResultW <= ALUResultM_o;
        ReadDataW  <= ReadDataM_i;
        RdW_o      <= RdM_o;
        ExtImmW    <= ExtImmM;
        PCPlus4W   <= PCPlus4M;
end

//Writeback and Pre-Fetch End

endmodule
