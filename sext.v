// iverilog -o sext.o sext.v & vvp sext.o
localparam K = 32;

// sign extend 8 => 32
function [(K-1):0] sext8(input [(N-1):0] b);
    localparam N = 8;
    sext8 = $signed({{(K - N) {b[(N-1)]}}, b[(N-2):0]});
endfunction

// sign extend 12 => 32
function [(K-1):0] sext12(input [(N-1):0] b);
    localparam N = 12;
    sext12 = $signed({{(K - N) {b[(N-1)]}}, b[(N-2):0]});
endfunction

// sign extend 16 => 32
function [(K-1):0] sext16(input [(N-1):0] b);
    localparam N = 16;
    sext16 = $signed({{(K - N) {b[(N-1)]}}, b[(N-2):0]});
endfunction

// sign extend 20 => 32
function [(K-1):0] sext20(input [(N-1):0] b);
    localparam N = 20;
    sext20 = $signed({{(K - N) {b[(N-1)]}}, b[(N-2):0]});
endfunction

// // test
// wire signed [7:0] s8 = -8'd99;  // 8-bits: byte
// wire signed [11:0] s12 = -12'd99;  // 8-bits: byte
// wire signed [15:0] s16 = -16'd99;  // 16-bits: half

// wire signed [(K-1):0] s8s = sext8(s8);
// wire signed [(K-1):0] s12s = sext12(s12);
// wire signed [(K-1):0] s16s = sext16(s16);

// initial begin
//     #1 $display("s8: (%0d)\ns12: (%0d)\ns16: (%0d)", s8s, s12s, s16s);
// end

