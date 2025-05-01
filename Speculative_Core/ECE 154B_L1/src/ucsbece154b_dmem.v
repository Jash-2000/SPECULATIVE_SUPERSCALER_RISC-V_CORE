// ucsbece154_dmem.v
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


module ucsbece154_dmem (
    input               clk, we_i,
    input        [31:0] a_i,
    input        [31:0] wd_i,
    output wire  [31:0] rd_o
);

localparam NUM_WORDS = 256;
localparam ADDR_WIDTH = $clog2(NUM_WORDS);

reg [31:0] RAM [0:NUM_WORDS-1];

assign rd_o = RAM[a_i[ADDR_WIDTH+1:2]];

always @ (posedge clk) begin
    if (we_i)
        RAM[a_i[ADDR_WIDTH+1:2]] <= wd_i;
`ifdef SIM
    if (we_i && (a_i[1:0]!=2'b0))
        $warning("Attempted to write to invalid address 0x%h. Address coerced to 0x%h.", a_i, (a_i&(~32'b11)));
`endif
end

endmodule
