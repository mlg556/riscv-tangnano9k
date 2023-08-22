`timescale 1ns / 1ns

module soc_tb ();

    reg clk = 0;
    reg btn1 = 1;
    wire [5:0] led;

    soc u0 (
        .clk (clk),
        .btn1(btn1),
        .led (led)
    );

    always begin
        #16 clk = ~clk;
    end

    initial begin
        $dumpfile("soc_tb.vcd");
        $dumpvars(0, soc_tb);

        $monitor("%d", led);

        #10_000_000 $finish;  // just in case

    end

endmodule
