//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for CLKS_PER_BIT clock cycles.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87

// in my case 27_000_000/115200 = 234

module uart_rx #(
    parameter CLKS_PER_BIT = 234
) (
    input        i_Clock,
    input        i_Rx_Serial,
    output       o_Rx_DV,
    output [7:0] o_Rx_Byte
);

    localparam s_IDLE = 3'b000;
    localparam s_RX_START_BIT = 3'b001;
    localparam s_RX_DATA_BITS = 3'b010;
    localparam s_RX_STOP_BIT = 3'b011;
    localparam s_CLEANUP = 3'b100;

    reg       r_Rx_Data_R = 1'b1;
    reg       r_Rx_Data = 1'b1;

    reg [7:0] r_Clock_Count = 0;
    reg [2:0] r_Bit_Index = 0;  //8 bits total
    reg [7:0] r_Rx_Byte = 0;
    reg       r_Rx_DV = 0;
    reg [2:0] r_SM_Main = 0;

    // Purpose: Double-register the incoming data.
    // This allows it to be used in the UART RX Clock Domain.
    // (It removes problems caused by metastability)
    always @(posedge i_Clock) begin
        r_Rx_Data_R <= i_Rx_Serial;
        r_Rx_Data   <= r_Rx_Data_R;
    end
    // Purpose: Control RX state machine
    always @(posedge i_Clock) begin

        case (r_SM_Main)
            s_IDLE: begin
                r_Rx_DV       <= 1'b0;
                r_Clock_Count <= 0;
                r_Bit_Index   <= 0;

                if (r_Rx_Data == 1'b0)  // Start bit detected
                    r_SM_Main <= s_RX_START_BIT;
                else r_SM_Main <= s_IDLE;
            end
            // Check middle of start bit to make sure it's still low
            s_RX_START_BIT: begin
                if (r_Clock_Count == (CLKS_PER_BIT - 1) / 2) begin
                    if (r_Rx_Data == 1'b0) begin
                        r_Clock_Count <= 0;  // reset counter, found the middle
                        r_SM_Main     <= s_RX_DATA_BITS;
                    end else r_SM_Main <= s_IDLE;
                end else begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_RX_START_BIT;
                end
            end  // case: s_RX_START_BIT
            // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
            s_RX_DATA_BITS: begin
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_RX_DATA_BITS;
                end else begin
                    r_Clock_Count          <= 0;
                    r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;

                    // Check if we have received all bits
                    if (r_Bit_Index < 7) begin
                        r_Bit_Index <= r_Bit_Index + 1;
                        r_SM_Main   <= s_RX_DATA_BITS;
                    end else begin
                        r_Bit_Index <= 0;
                        r_SM_Main   <= s_RX_STOP_BIT;
                    end
                end
            end  // case: s_RX_DATA_BITS
            // Receive Stop bit.  Stop bit = 1
            s_RX_STOP_BIT: begin
                // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_RX_STOP_BIT;
                end else begin
                    r_Rx_DV       <= 1'b1;
                    r_Clock_Count <= 0;
                    r_SM_Main     <= s_CLEANUP;
                end
            end  // case: s_RX_STOP_BIT
            // Stay here for CLKS_PER_BIT/2 clock cycles
            s_CLEANUP: begin
                if (r_Clock_Count < CLKS_PER_BIT / 2) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_CLEANUP;
                end else begin
                    r_SM_Main <= s_IDLE;
                    r_Rx_DV   <= 1'b0;
                end
            end
            default: r_SM_Main <= s_IDLE;
        endcase
    end
    assign o_Rx_DV   = r_Rx_DV;
    assign o_Rx_Byte = r_Rx_Byte;
endmodule  // uart_rx




//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87

module uart_tx #(
    parameter CLKS_PER_BIT = 234
) (
    input            i_Clock,
    input            i_Tx_DV,
    input      [7:0] i_Tx_Byte,
    output           o_Tx_Active,
    output reg       o_Tx_Serial,
    output           o_Tx_Done
);

    localparam s_IDLE = 3'b000;
    localparam s_TX_START_BIT = 3'b001;
    localparam s_TX_DATA_BITS = 3'b010;
    localparam s_TX_STOP_BIT = 3'b011;
    localparam s_CLEANUP = 3'b100;

    reg [2:0] r_SM_Main = 0;
    reg [7:0] r_Clock_Count = 0;
    reg [2:0] r_Bit_Index = 0;
    reg [7:0] r_Tx_Data = 0;
    reg       r_Tx_Done = 0;
    reg       r_Tx_Active = 0;

    always @(posedge i_Clock) begin
        case (r_SM_Main)
            s_IDLE: begin
                o_Tx_Serial   <= 1'b1;  // Drive Line High for Idle
                r_Tx_Done     <= 1'b0;
                r_Clock_Count <= 0;
                r_Bit_Index   <= 0;
                if (i_Tx_DV == 1'b1) begin
                    r_Tx_Active <= 1'b1;
                    r_Tx_Data   <= i_Tx_Byte;
                    r_SM_Main   <= s_TX_START_BIT;
                end else r_SM_Main <= s_IDLE;
            end  // case: s_IDLE
            // Send out Start Bit. Start bit = 0
            s_TX_START_BIT: begin
                o_Tx_Serial <= 1'b0;
                // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_TX_START_BIT;
                end else begin
                    r_Clock_Count <= 0;
                    r_SM_Main     <= s_TX_DATA_BITS;
                end
            end  // case: s_TX_START_BIT
            // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
            s_TX_DATA_BITS: begin
                o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_TX_DATA_BITS;
                end else begin
                    r_Clock_Count <= 0;
                    // Check if we have sent out all bits
                    if (r_Bit_Index < 7) begin
                        r_Bit_Index <= r_Bit_Index + 1;
                        r_SM_Main   <= s_TX_DATA_BITS;
                    end else begin
                        r_Bit_Index <= 0;
                        r_SM_Main   <= s_TX_STOP_BIT;
                    end
                end
            end  // case: s_TX_DATA_BITS
            // Send out Stop bit.  Stop bit = 1
            s_TX_STOP_BIT: begin
                o_Tx_Serial <= 1'b1;
                // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                    r_Clock_Count <= r_Clock_Count + 1;
                    r_SM_Main     <= s_TX_STOP_BIT;
                end else begin
                    r_Tx_Done     <= 1'b1;
                    r_Clock_Count <= 0;
                    r_SM_Main     <= s_CLEANUP;
                    r_Tx_Active   <= 1'b0;
                end
            end  // case: s_Tx_STOP_BIT
            // Stay here 1 clock
            s_CLEANUP: begin
                r_Tx_Done <= 1'b1;
                r_SM_Main <= s_IDLE;
            end
            default: r_SM_Main <= s_IDLE;
        endcase
    end
    assign o_Tx_Active = r_Tx_Active;
    assign o_Tx_Done   = r_Tx_Done;
endmodule
