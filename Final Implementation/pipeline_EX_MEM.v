module PipelineExMem(
    input clk, input rst,
    input [31:0] aluResIn,
    input [31:0] writeDataIn,
    input [5:0] dstRegIn,
    input  [31:0] pcPlusImmIn,
    input [2:0] wbCtrlIn, input [1:0] memCtrlIn,
    output reg [31:0] aluResOut,
    output reg [31:0] writeDataOut,
    output reg [5:0] dstRegOut,
    output reg [2:0] wbCtrlOut, output reg [1:0] memCtrlOut,
    output reg [31:0] pcPlusImmOut
);
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            aluResOut <= 0; writeDataOut <= 0; dstRegOut <= 0;
            wbCtrlOut <= 0; memCtrlOut <= 0;
            pcPlusImmOut <= 0;
        end else begin
            aluResOut <= aluResIn;
            writeDataOut <= writeDataIn;
            dstRegOut <= dstRegIn;
            wbCtrlOut <= wbCtrlIn;
            memCtrlOut <= memCtrlIn;
            pcPlusImmOut <= pcPlusImmIn;
        end
    end
endmodule