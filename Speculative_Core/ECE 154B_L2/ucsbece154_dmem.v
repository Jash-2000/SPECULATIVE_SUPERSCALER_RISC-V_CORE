// ucsbece154_dmem.v
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited

`define MIN(A,B) (((A)<(B))?(A):(B))

module ucsbece154_dmem #(
    parameter DATA_SIZE = 64
) (
    input               clk, we_i,
    input        [31:0] a_i,
    input        [31:0] wd_i,
    output wire  [31:0] rd_o
);

// instantiate/initialize BRAM
reg [31:0] DATA [0:DATA_SIZE-1];

// calculate address bounds for memory
localparam DATA_START = 32'h10000000;
localparam DATA_END   = `MIN( DATA_START + (DATA_SIZE*4), 32'h80000000);

// calculate address width
localparam DATA_ADDRESS_WIDTH = $clog2(DATA_SIZE);

// create flags to specify whether in-range 
wire data_enable = (DATA_START <= a_i) && (a_i < DATA_END);

// create addresses 
wire [DATA_ADDRESS_WIDTH-1:0] data_address = a_i[2 +: DATA_ADDRESS_WIDTH]-(DATA_START[2 +: DATA_ADDRESS_WIDTH]);

// get read-data 
wire [31:0] data_data = DATA[ data_address ];

// set rd_o iff a_i is in range 
assign rd_o =
    data_enable ? data_data :
    {32{1'bz}}; // not driven by this memory

// write routine
always @ (posedge clk) begin
    if (we_i) begin
        if (we_i && data_enable)
            DATA[data_address] <= wd_i;
`ifdef SIM
        if (a_i[1:0]!=2'b0)
            $warning("Attempted to write to invalid address 0x%h. Address coerced to 0x%h.", a_i, (a_i&(~32'b11)));
        if (!data_enable)
            $warning("Attempted to write to out-of-range address 0x%h.", (a_i&(~32'b11)));
`endif
    end
end

endmodule


`undef MIN
