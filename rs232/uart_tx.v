module uart_tx (
    input wire clk,           // System clock
    input wire reset,         // Reset signal
    input wire send,          // Trigger to start transmission
    input wire [7:0] data_in, // Data to be transmitted
    output reg tx,            // UART transmit line
    output reg ready          // Ready signal (high when idle)
);
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 50000000; // 50 MHz clock
    parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [3:0] bit_count;      // Tracks the bit being transmitted
    reg [15:0] clk_counter;   // Baud rate clock divider
    reg [9:0] shift_reg;      // Shift register for the UART frame
    reg busy;                 // Indicates transmission in progress

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1;          // Idle state for RS232 is HIGH
            ready <= 1;       // Transmitter is initially ready
            bit_count <= 0;
            clk_counter <= 0;
            shift_reg <= 10'b1111111111; // Empty shift register
            busy <= 0;
        end else begin
            if (!busy) begin
                if (send) begin
                    // Load shift register: STOP_BIT, DATA[7:0], START_BIT
                    shift_reg <= {1'b1, data_in, 1'b0};
                    ready <= 0;
                    busy <= 1;
                    bit_count <= 0;
                    clk_counter <= 0;
                end
            end else begin
                if (clk_counter == BIT_PERIOD - 1) begin
                    clk_counter <= 0;
                    tx <= shift_reg[0];         // Send the next bit
                    shift_reg <= shift_reg >> 1;// Shift out LSB
                    bit_count <= bit_count + 1;

                    if (bit_count == 9) begin
                        busy <= 0;             // Transmission complete
                        ready <= 1;
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
        end
    end
endmodule
