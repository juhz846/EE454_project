module uart_rx (
    input wire clk,         // System clock
    input wire reset,       // Reset signal
    input wire rx,          // UART receive line
    output reg [7:0] data_out, // Received 8-bit data
    output reg valid        // Indicates when data_out is valid
);
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 50000000; // 50 MHz clock
    parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE;
    parameter SAMPLE_POINT = BIT_PERIOD / 2;

    reg [3:0] bit_count;     // Tracks the number of received bits
    reg [15:0] clk_counter;  // Baud rate clock divider
    reg [7:0] shift_reg;     // Stores received bits
    reg busy;                // Indicates reception in progress

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid <= 0;
            busy <= 0;
            bit_count <= 0;
            clk_counter <= 0;
            shift_reg <= 0;
        end else begin
            if (!busy) begin
                if (rx == 0) begin // Detect start bit (falling edge)
                    busy <= 1;
                    clk_counter <= 0;
                    bit_count <= 0;
                    valid <= 0;
                end
            end else begin
                if (clk_counter == SAMPLE_POINT) begin
                    clk_counter <= 0;

                    if (bit_count < 8) begin
                        shift_reg[bit_count] <= rx; // Sample and shift in bits
                        bit_count <= bit_count + 1;
                    end else begin
                        data_out <= shift_reg;      // Output received data
                        valid <= 1;                // Indicate valid data
                        busy <= 0;                 // Done receiving
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
        end
    end
endmodule
