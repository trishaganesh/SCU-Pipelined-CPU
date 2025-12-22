module DataMemory(
    input clk,
    input memRead,
    input memWrite,
    input [31:0] address,
    input [31:0] writeData,
    output reg [31:0] readData
);
    reg [31:0] memory [0:1023];
    integer i;

    initial begin
        for(i=0; i<1024; i=i+1) memory[i] = 32'd0;
        
        memory[2] = 3;
        memory[3] = 1;
        memory[4] = 5;
        memory[5] = 7;
        memory[6] = 2;
        memory[7] = 9;
        memory[8] = 8;
    end

    always @(posedge clk) begin
        if (memWrite)
            memory[address[9:0]] <= writeData;
    end

    always @(*) begin
        if (memRead)
            readData = memory[address[9:0]];
        else
            readData = 32'd0;
    end
endmodule