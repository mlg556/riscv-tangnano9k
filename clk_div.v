module clk_div #(
    parameter N = 1
) (
    input  clk,
    output clk_out
);
    // slows down the clock by 2^N
    reg [N:0] counter = 0;

    always @(posedge clk) begin
        counter <= counter + 1;
    end

    assign clk_out = counter[N];

endmodule
