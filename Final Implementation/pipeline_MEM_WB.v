module PipelineMemWb(
    input clk, input rst,
    input [31:0] memDataIn,
    input [31:0] aluResIn,
    input [5:0] dstRegIn,
    input [2:0] wbCtrlIn,
    input  [31:0] pcPlusImmIn,
    output reg [31:0] memDataOut,
    output reg [31:0] aluResOut,
    output reg [5:0] dstRegOut,
    output reg [2:0] wbCtrlOut,
    output reg [31:0] pcPlusImmOut
);
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            memDataOut <= 0; aluResOut <= 0; dstRegOut <= 0; wbCtrlOut <= 0; pcPlusImmOut <= 0;
        end else begin
            memDataOut <= memDataIn;
            aluResOut <= aluResIn;
            dstRegOut <= dstRegIn;
            wbCtrlOut <= wbCtrlIn;
            pcPlusImmOut <= pcPlusImmIn;
        end
    end
endmodule