module ProgramCounter(
    input clk,
    input rst,
    input [31:0] jumpTarget,
    input pcSrc,
    output reg [31:0] pcOut
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pcOut <= 32'd0;
        else
            pcOut <= (pcSrc) ? jumpTarget : pcOut + 32'd1;
    end
endmodule