module RegisterFile(
    input clk,
    input writeEn,
    input [5:0] rsAddr,
    input [5:0] rtAddr,
    input [5:0] rdAddr,
    input [31:0] writeData,
    output reg [31:0] rsData,
    output reg [31:0] rtData
);
    reg [31:0] registers [0:63];
    integer i;

    initial begin
        for(i=0; i<64; i=i+1) registers[i] = 32'd0;
        
        // preset these register values to run given example for [3,1,5,7,2,9,8]
        registers[1] = 7;  // x1 = n = 7
        registers[2] = 2;  // x2 = &a = 2
        registers[3] = 71; // x3 = &b = 71
        
    end

    always @(posedge clk) begin
        if (writeEn) 
            registers[rdAddr] <= writeData;
    end

    always @(*) begin
        rsData = registers[rsAddr];
        rtData = registers[rtAddr];
    end
endmodule