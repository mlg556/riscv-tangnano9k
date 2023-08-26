`timescale 1ns / 1ns
// `include "uart.v"

module uart_tb ();

    reg clk = 0;
    reg uart_tx_en = 0;
    reg [7:0] uart_tx_data = "h";
    wire uart_tx_active;
    wire uart_conn;

    wire uart_rx_done;
    wire [7:0] uart_rx_data;


    uart_tx utx (
        .i_Clock(clk),
        .i_Tx_DV(uart_tx_en),
        .i_Tx_Byte(uart_tx_data),
        .o_Tx_Active(uart_tx_active),
        .o_Tx_Serial(uart_conn)
    );

    uart_rx urx (
        .i_Clock(clk),
        .i_Rx_Serial(uart_conn),
        .o_Rx_DV(uart_rx_done),
        .o_Rx_Byte(uart_rx_data)
    );

    always begin
        #16 clk = ~clk;
    end

    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);
        //$monitor("%d", led);

        #20 uart_tx_en = 1;

        #100_000 uart_tx_data = "e";

        #200_000 $finish;  // just in case

    end

endmodule
