`timescale 1ns / 1ps

module tb_datapath();

    reg clk;
    reg reset;

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    Datapath test(clk, reset);

    initial begin
        reset = 1;
        #10;
        reset = 0;

        #5000;
        $finish;
    end

endmodule
