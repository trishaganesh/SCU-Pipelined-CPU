`include "Parameters.v"

module Datapath(
    input clk,
    input rst
);
    wire [31:0] pcCurrent, instruction, branchTarget;
    wire pcSrc; 

    // IF/ID
    wire [31:0] idPc, idInst;
    
    // ID Signals
    //extracting fields from instruction
    wire [3:0] opcode = idInst[3:0];
    wire [5:0] rtAddr = idInst[9:4];
    wire [5:0] rsAddr = idInst[15:10];
    wire [5:0] rdAddr = idInst[21:16];
    
    wire [31:0] signExtImm; //immediate generated from instruction
    wire [31:0] regRData1, regRData2; //register both rs and rt data
    //the control signals from the control Unit
    wire regWrite, memRead, memWrite, aluSrc, memToReg, svpc, jump, branchZ, branchN;
    wire [2:0] aluOp;
    
    // EX Signals
    wire [31:0] exPc, exRData1, exRData2, exImm;
    wire [5:0] exRd, exRs, exRt;
    wire [2:0] exWbCtrl;
    wire [1:0] exMemCtrl; 
    wire [6:0] exExCtrl;
    wire [31:0] exPcPlusImm;
    
    wire [31:0] aluInA, aluInB, exAluRes;
    wire exZ, exN; //the ALU N and Z flags
    reg statusZ, statusN; //the status flags
    
    // MEM Signals
    wire [31:0] memAluRes, memWriteData, memReadData;
    wire [5:0] memDstReg;
    wire [2:0] memWbCtrl;
    wire [1:0] memMemCtrl;
    wire [31:0] memPcPlusImm;
    
    // WB Signals
    wire [31:0] wbMemData, wbAluRes, wbMux1Data, wbFinalData;
    wire [5:0] wbDstReg;
    wire [31:0] wbPcPlusImm;
    wire [2:0] wbWbCtrl;

    assign branchTarget = exRData1; // Jump/Branch to register value (rs)
    
    assign pcSrc = (exExCtrl[6]) ||                   // Jump
                   (exExCtrl[5] && statusZ) ||        // BRZ
                   (exExCtrl[4] && statusN);          // BRN

    // IF Stage
    ProgramCounter PC (
        .clk(clk), .rst(rst),
        .jumpTarget(branchTarget), //PC = rs on branch/jump
        .pcSrc(pcSrc),
        .pcOut(pcCurrent)
    );

    InstructionMemory IM (
        .address(pcCurrent),
        .instruction(instruction)
    );

    PipelineIfId IF_ID (
        .clk(clk), .rst(rst),
        .pcIn(pcCurrent), .instIn(instruction),
        .pcOut(idPc), .instOut(idInst)
    );

    // ID Stage
    ImmediateGenerator ImmGen (
        .instruction(idInst),
        .immediateOut(signExtImm)
    );

    ControlUnit CU (
        .opcode(opcode),
        .regWrite(regWrite),
        .memRead(memRead), .memWrite(memWrite),
        .aluSrc(aluSrc), .memToReg(memToReg), .aluOp(aluOp),
        .svpc(svpc), .jump(jump), .branchZ(branchZ), .branchN(branchN)
    );

    RegisterFile RF (
        .clk(clk),
        .writeEn(wbWbCtrl[0]), // WB Control Bit 0: RegWrite
        .rsAddr(rsAddr), .rtAddr(rtAddr),
        .rdAddr(wbDstReg),
        .writeData(wbFinalData),
        .rsData(regRData1), .rtData(regRData2)
    );

    PipelineIdEx ID_EX (
        .clk(clk), .rst(rst),
        .pcIn(idPc),
        .rData1In(regRData1), .rData2In(regRData2),
        .immIn(signExtImm),
        .rdIn(rdAddr), .rsIn(rsAddr), .rtIn(rtAddr),
        .wbCtrlIn({svpc, memToReg, regWrite}),
        .memCtrlIn({memRead, memWrite}),
        .exCtrlIn({jump, branchZ, branchN, aluSrc, aluOp[2:0]}),
        .pcOut(exPc),
        .rData1Out(exRData1), .rData2Out(exRData2),
        .immOut(exImm),
        .rdOut(exRd), .rsOut(exRs), .rtOut(exRt),
        .wbCtrlOut(exWbCtrl), .memCtrlOut(exMemCtrl), 
        .exCtrlOut(exExCtrl)
    );

    // EX Stage
    
    // Computing PC+Imm for possible branch target
    assign exPcPlusImm = exPc + exImm;
    
    // ALU input A is always rs
    assign aluInA = exRData1;
    
    // Mux for ALU Input B: Selects Imm if ALUSrc is active, else rt
    assign aluInB = (exExCtrl[3]) ? exImm : exRData2;

    Alu ALU (
        .a(aluInA), .b(aluInB),
        .op({1'b0, exExCtrl[2:0]}),
        .res(exAluRes),
        .z(exZ), .n(exN)
    );

    //the status register captures flags for use by next instruction's branch
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            statusZ <= 0; statusN <= 0;
        end else begin
            statusZ <= exZ; statusN <= exN;
        end
    end

    PipelineExMem EX_MEM (
        .clk(clk), .rst(rst),
        .aluResIn(exAluRes),
        .writeDataIn(exRData2),
        .dstRegIn(exRd),
        .wbCtrlIn(exWbCtrl), .memCtrlIn(exMemCtrl),
        .pcPlusImmIn(exPcPlusImm),
        .aluResOut(memAluRes),
        .writeDataOut(memWriteData),
        .dstRegOut(memDstReg),
        .wbCtrlOut(memWbCtrl), .memCtrlOut(memMemCtrl),
        .pcPlusImmOut(memPcPlusImm)
    );

    // MEM Stage
    DataMemory DM (
        .clk(clk),
        .memRead(memMemCtrl[1]), .memWrite(memMemCtrl[0]),
        .address(memAluRes),
        .writeData(memWriteData),
        .readData(memReadData)
    );

    PipelineMemWb MEM_WB (
        .clk(clk), .rst(rst),
        .memDataIn(memReadData),
        .aluResIn(memAluRes),
        .dstRegIn(memDstReg),
        .wbCtrlIn(memWbCtrl),
        .pcPlusImmIn(memPcPlusImm),
        .memDataOut(wbMemData),
        .aluResOut(wbAluRes),
        .dstRegOut(wbDstReg),
        .wbCtrlOut(wbWbCtrl),
        .pcPlusImmOut(wbPcPlusImm)
    );

    // WB Stage
    // 1st Mux
    assign wbMux1Data = (wbWbCtrl[1]) ? wbMemData : wbAluRes;

    // 2nd Mux
    assign wbFinalData = (wbWbCtrl[2]) ? wbPcPlusImm : wbMux1Data;

endmodule