`timescale 1ns / 1ns

module soc_tb ();

    reg clk = 0;
    wire [5:0] led;

    soc u0 (
        .clk(clk),
        .led(led)
    );

    always begin
        #16 clk = ~clk;
    end

    initial begin
        $dumpfile("soc_tb.vcd");
        $dumpvars(0, soc_tb);

        //$monitor("%d", led);

        #500_000 $finish;  // just in case

    end

endmodule
