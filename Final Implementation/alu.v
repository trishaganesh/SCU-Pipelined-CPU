module Alu(
    input [31:0] a,
    input [31:0] b,
    input [2:0] op,
    output reg [31:0] res,
    output wire z,
    output wire n
);
// ALU opcodes
    wire add = (op == 3'b000); 
    wire neg = (op == 3'b110);
    wire sub = (op == 3'b101);

// Perform operation based on the specified code
    always @(*) begin
        if (add)      res = a + b;
        else if (sub) res = a - b;
        else if (neg) res = -a;
        else          res = 32'd0;
    end
// Track Z and N flags for zero and negative values
    assign z = (res == 32'd0);
    assign n = res[31];
endmodule