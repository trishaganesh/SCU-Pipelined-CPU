module PipelineIdEx(
    input clk, input rst,
    input [31:0] pcIn,
    input [31:0] rData1In, input [31:0] rData2In,
    input [31:0] immIn,
    input [5:0] rdIn, input [5:0] rsIn, input [5:0] rtIn,
    input [2:0] wbCtrlIn, input [1:0] memCtrlIn, input [6:0] exCtrlIn,
    output reg [31:0] pcOut,
    output reg [31:0] rData1Out, output reg [31:0] rData2Out,
    output reg [31:0] immOut,
    output reg [5:0] rdOut, output reg [5:0] rsOut, output reg [5:0] rtOut,
    output reg [2:0] wbCtrlOut, output reg [1:0] memCtrlOut, output reg [6:0] exCtrlOut
);
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            pcOut <= 0; rData1Out <= 0; rData2Out <= 0; immOut <= 0;
            rdOut <= 0; rsOut <= 0; rtOut <= 0;
            wbCtrlOut <= 0; memCtrlOut <= 0; exCtrlOut <= 0;
        end else begin
            pcOut <= pcIn;
            rData1Out <= rData1In; rData2Out <= rData2In;
            immOut <= immIn;
            rdOut <= rdIn; rsOut <= rsIn; rtOut <= rtIn;
            wbCtrlOut <= wbCtrlIn; memCtrlOut <= memCtrlIn; exCtrlOut <= exCtrlIn;
        end
    end
endmodule