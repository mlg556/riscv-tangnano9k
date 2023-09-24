// `default_nettype none
`include "uart.v"

module Memory (
    input             clk,
    input      [31:0] mem_addr,   // address to be read
    output reg [31:0] mem_rdata,  // data read from memory
    input             mem_rstrb,  // goes high when processor wants to read
    input      [31:0] mem_wdata,  // data to be written
    input      [ 3:0] mem_wmask   // masks for writing the 4 bytes (1=write byte) 
);

    // 8192 4-bytes words => 32768 B = 32KB (RAM + ROM)
    // maybe:
    // [0x0000 => 0x3FFF] ROM
    // [0x4000 => 0x7FFF] RAM

    reg [31:0] MEM[0:8_191];
    initial begin
        $readmemh("src/helloc.hex", MEM);
    end

    wire [29:0] word_addr = mem_addr[31:2];

    always @(posedge clk) begin
        if (mem_rstrb) begin
            mem_rdata <= MEM[word_addr];
        end
        if (mem_wmask[0]) MEM[word_addr][7:0] <= mem_wdata[7:0];
        if (mem_wmask[1]) MEM[word_addr][15:8] <= mem_wdata[15:8];
        if (mem_wmask[2]) MEM[word_addr][23:16] <= mem_wdata[23:16];
        if (mem_wmask[3]) MEM[word_addr][31:24] <= mem_wdata[31:24];
    end
endmodule


module Processor (
    input         clk,
    input         resetn,
    output [31:0] mem_addr,
    input  [31:0] mem_rdata,
    output        mem_rstrb,
    output [31:0] mem_wdata,
    output [ 3:0] mem_wmask
);

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


    reg  [31:0] PC = 0;  // program counter
    reg  [31:0] instr;  // current instruction

    wire [ 6:0] opcode = instr[6:0];

    // See the table P. 105 in RISC-V manual

    // The 10 RISC-V instructions
    wire        OPC_REG = (opcode == 7'b0110011);  // rd <- rs1 OP rs2   
    wire        OPC_IMM = (opcode == 7'b0010011);  // rd <- rs1 OP I_imm
    wire        OPC_BRANCH = (opcode == 7'b1100011);  // if(rs1 OP rs2) PC<-PC+B_imm
    wire        OPC_JALR = (opcode == 7'b1100111);  // rd <- PC+4; PC<-rs1+I_imm
    wire        OPC_JAL = (opcode == 7'b1101111);  // rd <- PC+4; PC<-PC+J_imm
    wire        OPC_AUIPC = (opcode == 7'b0010111);  // rd <- PC + U_imm
    wire        OPC_LUI = (opcode == 7'b0110111);  // rd <- U_imm   
    wire        OPC_LOAD = (opcode == 7'b0000011);  // rd <- mem[rs1+I_imm]
    wire        OPC_STORE = (opcode == 7'b0100011);  // mem[rs1+S_imm] <- rs2
    wire        OPC_SYS = (opcode == 7'b1110011);  // special

    // immediate fields
    wire [31:0] I_imm = sext12(instr[31:20]);
    wire [31:0] S_imm = sext12({instr[31:25], instr[11:7]});
    wire [31:0] B_imm = sext12({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
    wire [31:0] U_imm = {instr[31:12], {12{1'b0}}};
    wire [31:0] J_imm = sext20({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});

    // Source and destination registers
    wire [ 4:0] rs1_id = instr[19:15];
    wire [ 4:0] rs2_id = instr[24:20];
    wire [ 4:0] rd_id = instr[11:7];

    // function codes
    wire [ 2:0] funct3 = instr[14:12];
    wire [ 6:0] funct7 = instr[31:25];

    // The registers bank
    reg  [31:0] RA                                                                       [0:31];
    reg  [31:0] rs1;  // value of source
    reg  [31:0] rs2;  //  registers.
    wire [31:0] wb_data;  // data to be written to rd
    wire        wb_en;  // asserted if data should be written to rd

`ifdef BENCH
    integer i;
    initial begin
        for (i = 0; i < 32; i++) begin
            RA[i] = 0;
        end

        //$monitor("PC: %d", PC);
    end
`endif

    // The ALU
    wire [31:0] aluIn1 = rs1;
    wire [31:0] aluIn2 = OPC_REG ? rs2 : I_imm;
    reg  [31:0] aluOut;
    wire [ 4:0] shamt = OPC_REG ? rs2[4:0] : instr[24:20];  // shift amount

    // ADD/SUB/ADDI: 
    // funct7[5] is 1 for SUB and 0 for ADD. We need also to test instr[5]
    // to make the difference with ADDI
    //
    // SRLI/SRAI/SRL/SRA: 
    // funct7[5] is 1 for arithmetic shift (SRA/SRAI) and 
    // 0 for logical shift (SRL/SRLI)
    always @(*) begin
        case (funct3)
            3'b000: aluOut = (funct7[5] & instr[5]) ? (aluIn1 - aluIn2) : (aluIn1 + aluIn2);
            3'b001: aluOut = aluIn1 << shamt;
            3'b010: aluOut = ($signed(aluIn1) < $signed(aluIn2));
            3'b011: aluOut = (aluIn1 < aluIn2);
            3'b100: aluOut = (aluIn1 ^ aluIn2);
            3'b101: aluOut = funct7[5] ? ($signed(aluIn1) >>> shamt) : ($signed(aluIn1) >> shamt);
            3'b110: aluOut = (aluIn1 | aluIn2);
            3'b111: aluOut = (aluIn1 & aluIn2);
        endcase
    end

    // The predicate for branch instructions
    reg takeBranch;
    always @(*) begin
        case (funct3)
            3'b000:  takeBranch = (rs1 == rs2);
            3'b001:  takeBranch = (rs1 != rs2);
            3'b100:  takeBranch = ($signed(rs1) < $signed(rs2));
            3'b101:  takeBranch = ($signed(rs1) >= $signed(rs2));
            3'b110:  takeBranch = (rs1 < rs2);
            3'b111:  takeBranch = (rs1 >= rs2);
            default: takeBranch = 1'b0;
        endcase
    end


    // next PC
    wire [31:0] nextPC = (OPC_BRANCH && takeBranch) ? PC+B_imm  :	       
   	                OPC_JAL                    ? PC+J_imm  :
	                OPC_JALR                   ? rs1+I_imm :
	                PC+4;
    wire [31:0] loadstore_addr = rs1 + (OPC_STORE ? S_imm : I_imm);


    // register write back
    assign wb_data = (OPC_JAL || OPC_JALR) ? PC+4   :
			      OPC_LUI         ? U_imm      :
			      OPC_AUIPC       ? PC+U_imm :
			      OPC_LOAD        ? LOAD_data :
			                      aluOut;

    // this one just for display ---.
    //                              v
    assign wb_en = (state==EXECUTE && !OPC_BRANCH && !OPC_STORE && !OPC_LOAD) ||
			(state==WAIT_DATA) ;


    // Load
    // All memory accesses are aligned on 32 bits boundary. For this
    // reason, we need some circuitry that does unaligned halfword
    // and byte load/store, based on:
    // - funct3[1:0]:  00->byte 01->halfword 10->word
    // - mem_addr[1:0]: indicates which byte/halfword is accessed

    wire mem_byteAccess = funct3[1:0] == 2'b00;
    wire mem_halfwordAccess = funct3[1:0] == 2'b01;


    wire [15:0] LOAD_halfword = loadstore_addr[1] ? mem_rdata[31:16] : mem_rdata[15:0];

    wire [7:0] LOAD_byte = loadstore_addr[0] ? LOAD_halfword[15:8] : LOAD_halfword[7:0];

    // LOAD, in addition to funct3[1:0], LOAD depends on:
    // - funct3[2] (instr[14]): 0->do sign expansion   1->no sign expansion
    wire LOAD_sign = !funct3[2] & (mem_byteAccess ? LOAD_byte[7] : LOAD_halfword[15]);

    wire [31:0] LOAD_data =
         mem_byteAccess ? {{24{LOAD_sign}},     LOAD_byte} :
     mem_halfwordAccess ? {{16{LOAD_sign}}, LOAD_halfword} :
                          mem_rdata ;

    // Store
    // ------------------------------------------------------------------------

    assign mem_wdata[7:0] = rs2[7:0];
    assign mem_wdata[15:8] = loadstore_addr[0] ? rs2[7:0] : rs2[15:8];
    assign mem_wdata[23:16] = loadstore_addr[1] ? rs2[7:0] : rs2[23:16];
    assign mem_wdata[31:24] = loadstore_addr[0] ? rs2[7:0]  :
			     loadstore_addr[1] ? rs2[15:8] : rs2[31:24];

    // The memory write mask:
    //    1111                     if writing a word
    //    0011 or 1100             if writing a halfword
    //                                (depending on loadstore_addr[1])
    //    0001, 0010, 0100 or 1000 if writing a byte
    //                                (depending on loadstore_addr[1:0])

    wire [3:0] STORE_wmask =
	      mem_byteAccess      ?
	            (loadstore_addr[1] ?
		          (loadstore_addr[0] ? 4'b1000 : 4'b0100) :
		          (loadstore_addr[0] ? 4'b0010 : 4'b0001)
                    ) :
	      mem_halfwordAccess ?
	            (loadstore_addr[1] ? 4'b1100 : 4'b0011) :
              4'b1111;



    // The state machine
    localparam FETCH_INSTR = 0;
    localparam WAIT_INSTR = 1;
    localparam FETCH_REGS = 2;
    localparam EXECUTE = 3;
    localparam LOAD = 4;
    localparam WAIT_DATA = 5;
    localparam STORE = 6;
    reg [2:0] state = FETCH_INSTR;

    always @(posedge clk) begin
        if (!resetn) begin
            PC    <= 0;
            state <= FETCH_INSTR;
        end else begin
            if (wb_en && rd_id != 0) begin
                RA[rd_id] <= wb_data;
            end
            case (state)
                FETCH_INSTR: begin
                    state <= WAIT_INSTR;
                end
                WAIT_INSTR: begin
                    instr <= mem_rdata;
                    state <= FETCH_REGS;
                end
                FETCH_REGS: begin
                    rs1   <= RA[rs1_id];
                    rs2   <= RA[rs2_id];
                    state <= EXECUTE;
                end
                EXECUTE: begin
                    if (!OPC_SYS) begin
                        PC <= nextPC;
                    end
                    state <= OPC_LOAD ? LOAD : OPC_STORE ? STORE : FETCH_INSTR;
                    // `ifdef BENCH
                    //if (OPC_SYS) $finish();
                    // `endif
                end
                LOAD: begin
                    state <= WAIT_DATA;
                end
                WAIT_DATA: begin
                    state <= FETCH_INSTR;
                end
                STORE: begin
                    state <= FETCH_INSTR;
                end
            endcase
        end
    end


    assign mem_addr  = (state == WAIT_INSTR || state == FETCH_INSTR) ? PC : loadstore_addr;
    assign mem_rstrb = (state == FETCH_INSTR || state == LOAD);
    assign mem_wmask = {4{(state == STORE)}} & STORE_wmask;

endmodule



module soc (
    input            clk,  // system clock
    input            rx,
    output           tx,
    output reg [5:0] led   // system LEDs
);

    wire [31:0] mem_addr;
    wire [31:0] mem_rdata;
    wire        mem_rstrb;
    wire [31:0] mem_wdata;
    wire [ 3:0] mem_wmask;

    Processor CPU (
        .clk(clk),
        .resetn(1'b1),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .mem_rstrb(mem_rstrb),
        .mem_wdata(mem_wdata),
        .mem_wmask(mem_wmask)
    );

    wire [31:0] RAM_rdata;
    wire [29:0] mem_wordaddr = mem_addr[31:2];
    wire        isIO = mem_addr[22];
    wire        isRAM = !isIO;
    wire        mem_wstrb = |mem_wmask;

    Memory RAM (
        .clk(clk),
        .mem_addr(mem_addr),
        .mem_rdata(RAM_rdata),
        .mem_rstrb(isRAM & mem_rstrb),
        .mem_wdata(mem_wdata),
        .mem_wmask({4{isRAM}} & mem_wmask)
    );

    // Memory-mapped IO in IO page, 1-hot addressing in word address.   
    localparam IO_LEDS_bit = 0;  // W five leds
    localparam IO_UART_TX_DATA_bit = 1;  // W data to send (8 bits) 
    localparam IO_UART_RX_DATA_bit = 2;  // W data to send (8 bits) 
    localparam IO_UART_CTRL = 3;  // R status. bit 0: busy sending

    // if it's an IO address (bit22=1) AND it's a write AND the address is LEDS
    always @(posedge clk) begin
        if (isIO & mem_wstrb & mem_wordaddr[IO_LEDS_bit]) begin
            led <= mem_wdata[5:0];
        end
    end

    // if it's an IO address (bit22=1) AND it's a write AND the address is uart_tx device
    wire uart_tx_en = isIO & mem_wstrb & mem_wordaddr[IO_UART_TX_DATA_bit];
    // if it's an IO address (bit22=1) AND it's a read AND the address is uart_rx device
    // wire uart_rx_en = isIO & ~mem_wstrb & mem_wordaddr[IO_UART_RX_DATA_bit];

    wire uart_tx_done;
    wire uart_rx_done;

    wire [7:0] uart_rx_data;

    uart_tx UART_TX (
        .i_Clock(clk),
        .i_Tx_DV(uart_tx_en),
        .i_Tx_Byte(mem_wdata[7:0]),
        .o_Tx_Active(uart_tx_done),
        .o_Tx_Serial(tx)
    );

    uart_rx UART_RX (
        .i_Clock(clk),
        .i_Rx_Serial(rx),
        .o_Rx_DV(uart_rx_done),
        .o_Rx_Byte(uart_rx_data)
    );

    wire [31:0] IO_rdata;

    // bit0 set -> tx done (not active)
    // bit1 set -> rx done

    assign IO_rdata =   mem_wordaddr[IO_UART_RX_DATA_bit] ? uart_rx_data :
                        mem_wordaddr[IO_UART_CTRL] ? {30'b0, uart_rx_done, !uart_tx_done} :
                        32'b0;

    assign mem_rdata = isRAM ? RAM_rdata : IO_rdata;


endmodule
