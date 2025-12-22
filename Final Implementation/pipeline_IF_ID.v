module PipelineIfId(
    input clk, input rst,
    input [31:0] pcIn,
    input [31:0] instIn,
    output reg [31:0] pcOut,
    output reg [31:0] instOut
);
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            pcOut <= 0; instOut <= 0;
        end else begin
            pcOut <= pcIn; instOut <= instIn;
        end
    end
endmodule