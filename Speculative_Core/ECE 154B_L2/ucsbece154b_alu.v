// ucsbece154b_alu.v
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


module ucsbece154b_alu (
    input        [31:0] a_i, b_i,
    input         [2:0] alucontrol_i,
    output reg   [31:0] result_o,
    output wire         zero_o
);

`include "ucsbece154b_defines.vh"

// (This design uses 3 adders)
always @ * begin
    case (alucontrol_i)
        ALUcontrol_and: result_o = a_i & b_i;
        ALUcontrol_or: result_o = a_i | b_i;
        ALUcontrol_add: result_o = a_i + b_i;
        ALUcontrol_sub: result_o = a_i - b_i;
        ALUcontrol_slt: result_o = {31'b0, ($signed(a_i)<$signed(b_i))};
        default: begin
            `ifdef SIM
                 $warning("Unsupported ALUOp given: %h", alucontrol_i);
            `endif
            result_o = {32{1'bx}};
        end
    endcase
end

assign zero_o = (result_o == 32'b0);

endmodule
