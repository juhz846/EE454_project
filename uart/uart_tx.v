module uart_tx (
    input wire clk,          // System clock (50 MHz)
    input wire reset,        // Reset signal
    input wire send,         // Trigger to send data
    input wire [7:0] data_in,// Data to be sent
    output reg tx,           // Serial output
    output reg ready         // Ready to send next data
);
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 50000000; // 50 MHz clock
    parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [3:0] bit_count;      // Bit counter
    reg [15:0] clk_counter;   // Clock divider counter
    reg [9:0] shift_reg;      // Shift register for serializing data
    reg busy;                 // Busy flag for transmission

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1;          // Default idle state for TX is HIGH
            ready <= 1;
            bit_count <= 0;
            clk_counter <= 0;
            busy <= 0;
            shift_reg <= 10'b1111111111;
        end else begin
            if (!busy) begin
                if (send && ready) begin
                    // Start transmission
                    shift_reg <= {1'b1, data_in, 1'b0}; // Stop bit, data, start bit
                    ready <= 0;
                    busy <= 1;
                    bit_count <= 0;
                    clk_counter <= 0;
                end
            end else begin
                if (clk_counter == BIT_PERIOD) begin
                    clk_counter <= 0;
                    tx <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count + 1;

                    if (bit_count == 9) begin
                        busy <= 0;
                        ready <= 1;
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
        end
    end
endmodule
