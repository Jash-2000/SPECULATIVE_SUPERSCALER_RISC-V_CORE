// ucsbece154b_top_tb.v
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


`define SIM

`define ASSERT(CONDITION, MESSAGE) if ((CONDITION)==1'b1); else begin $error($sformatf MESSAGE); end

module ucsbece154b_top_tb ();

// test bench contents
reg clk = 1;
always #1 clk <= ~clk;
reg reset;

ucsbece154b_top top (
    .clk(clk), .reset(reset)
);

wire [31:0] reg_zero = top.riscv.dp.rf.zero;
wire [31:0] reg_ra = top.riscv.dp.rf.ra;
wire [31:0] reg_sp = top.riscv.dp.rf.sp;
wire [31:0] reg_gp = top.riscv.dp.rf.gp;
wire [31:0] reg_tp = top.riscv.dp.rf.tp;
wire [31:0] reg_t0 = top.riscv.dp.rf.t0;
wire [31:0] reg_t1 = top.riscv.dp.rf.t1;
wire [31:0] reg_t2 = top.riscv.dp.rf.t2;
wire [31:0] reg_s0 = top.riscv.dp.rf.s0;
wire [31:0] reg_s1 = top.riscv.dp.rf.s1;
wire [31:0] reg_a0 = top.riscv.dp.rf.a0;
wire [31:0] reg_a1 = top.riscv.dp.rf.a1;
wire [31:0] reg_a2 = top.riscv.dp.rf.a2;
wire [31:0] reg_a3 = top.riscv.dp.rf.a3;
wire [31:0] reg_a4 = top.riscv.dp.rf.a4;
wire [31:0] reg_a5 = top.riscv.dp.rf.a5;
wire [31:0] reg_a6 = top.riscv.dp.rf.a6;
wire [31:0] reg_a7 = top.riscv.dp.rf.a7;
wire [31:0] reg_s2 = top.riscv.dp.rf.s2;
wire [31:0] reg_s3 = top.riscv.dp.rf.s3;
wire [31:0] reg_s4 = top.riscv.dp.rf.s4;
wire [31:0] reg_s5 = top.riscv.dp.rf.s5;
wire [31:0] reg_s6 = top.riscv.dp.rf.s6;
wire [31:0] reg_s7 = top.riscv.dp.rf.s7;
wire [31:0] reg_s8 = top.riscv.dp.rf.s8;
wire [31:0] reg_s9 = top.riscv.dp.rf.s9;
wire [31:0] reg_s10 = top.riscv.dp.rf.s10;
wire [31:0] reg_s11 = top.riscv.dp.rf.s11;
wire [31:0] reg_t3 = top.riscv.dp.rf.t3;
wire [31:0] reg_t4 = top.riscv.dp.rf.t4;
wire [31:0] reg_t5 = top.riscv.dp.rf.t5;
wire [31:0] reg_t6 = top.riscv.dp.rf.t6;

wire [31:0] MEM_10000000 = top.dmem.DATA[6'd0];
wire [31:0] MEM_10000004 = top.dmem.DATA[6'd1];
wire [31:0] MEM_10000008 = top.dmem.DATA[6'd2];
wire [31:0] MEM_1000000c = top.dmem.DATA[6'd3];
wire [31:0] MEM_10000060 = top.dmem.DATA[6'd24];
wire [31:0] MEM_10000064 = top.dmem.DATA[6'd25];
wire [31:0] MEM_10000068 = top.dmem.DATA[6'd26];
wire [31:0] MEM_1000006C = top.dmem.DATA[6'd27];
wire [31:0] MEM_10000070 = top.dmem.DATA[6'd28];

//

integer i;
initial begin
$display( "Begin simulation." );
//\\ =========================== \\//

reset = 1;
@(negedge clk);
@(negedge clk);
reset = 0;

/// MODIFY YOUR TEST

// Test for program 1
for (i = 0; i < 100; i=i+1)
    @(negedge clk);

`ASSERT(reg_zero==32'b0, ("reg_zero incorrect"));
`ASSERT(reg_sp==32'hBEEF000, ("reg_sp incorrect"));
`ASSERT(reg_gp==32'h1000004C, ("reg_gp incorrect"));
`ASSERT(reg_tp==32'h1, ("reg_tp incorrect"));
`ASSERT(reg_t0==32'hb, ("reg_t0 incorrect"));
`ASSERT(reg_t2==32'h7, ("reg_t2 incorrect"));
`ASSERT(MEM_10000060==32'h7, ("mem.DATA[25] incorrect"));
`ASSERT(MEM_1000006C==32'h19, ("mem.DATA[28] incorrect"));
`ASSERT(MEM_10000070==32'hBEEF000, ("mem.DATA[29] //incorrect"));


//\\ =========================== \\//
$display( "End simulation.");
$stop;
end

endmodule

`undef ASSERT
