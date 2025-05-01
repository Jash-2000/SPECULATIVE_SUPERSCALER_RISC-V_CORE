// ucsbece154_imem.v
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


module ucsbece154_imem (
    input        [31:0] a_i,
    output wire  [31:0] rd_o
);

localparam NUM_WORDS = 64;
localparam ADDR_WIDTH = $clog2(NUM_WORDS);

reg [31:0] RAM [0:NUM_WORDS-1];

// initialize memory with test program. Change this with your file for running custom code
initial $readmemh("memfile.dat", RAM);

assign rd_o = RAM[a_i[ADDR_WIDTH+1:2]]; // word aligned

`ifdef SIM
always @ * begin
    if (a_i[1:0]!=2'b0)
        $warning("Attempted to access invalid address 0x%h. Address coerced to 0x%h.", a_i, (a_i&(~32'b11)));
end
`endif

endmodule
