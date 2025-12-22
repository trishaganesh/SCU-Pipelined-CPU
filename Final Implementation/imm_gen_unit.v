module ImmediateGenerator(
    input [31:0] instruction,
    output reg [31:0] immediateOut
);
    wire [9:0] immField = instruction[31:22];

    always @(*) begin
        immediateOut = {{22{immField[9]}}, immField};
    end
endmodule