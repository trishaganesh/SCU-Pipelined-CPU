`include "Parameters.v"

module ControlUnit(
    input [3:0] opcode,
    output reg regWrite,
    output reg memRead,
    output reg memWrite,
    output reg aluSrc,
    output reg memToReg,
    output reg [2:0] aluOp,
    output reg svpc,
    output reg jump,
    output reg branchZ,
    output reg branchN
);
    always @(*) begin
        regWrite = 0; memRead = 0; memWrite = 0;
        aluSrc = 0; memToReg = 0; aluOp = 3'b000; 
        svpc = 0; jump = 0; branchZ = 0; branchN = 0;

        case (opcode)
            `OP_SVPC: begin 
                regWrite = 1; aluSrc = 1; svpc = 1; aluOp = 3'b000; // ALU Add
            end
            `OP_LD: begin 
                regWrite = 1; memRead = 1; aluSrc = 1; memToReg = 1; 
            end
            `OP_ST: begin 
                memWrite = 1; aluSrc = 1; 
            end
            `OP_ADD: begin 
                regWrite = 1; aluOp = 3'b000; 
            end
            `OP_INC: begin 
                regWrite = 1; aluSrc = 1; aluOp = 3'b000; 
            end
            `OP_NEG: begin 
                regWrite = 1; aluOp = 3'b110; 
            end
            `OP_SUB: begin 
                regWrite = 1; aluOp = 3'b101; 
            end
            `OP_J: begin 
                jump = 1; 
            end
            `OP_BRZ: begin 
                branchZ = 1; 
            end
            `OP_BRN: begin 
                branchN = 1; 
            end
        endcase
    end
endmodule