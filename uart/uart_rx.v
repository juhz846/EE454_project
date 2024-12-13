module uart_rx (
    input wire clk,         // System clock (50 MHz)
    input wire reset,       // Reset signal
    input wire rx,          // Serial input
    output reg [7:0] data_out, // Received data
    output reg valid        // Data valid flag
);
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 50000000; // 50 MHz clock
    parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE;
    parameter SAMPLE_POINT = BIT_PERIOD / 2;

    reg [3:0] bit_count;
    reg [15:0] clk_counter;
    reg [7:0] shift_reg;
    reg busy;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid <= 0;
            busy <= 0;
            bit_count <= 0;
            clk_counter <= 0;
        end else begin
            if (!busy) begin
                if (rx == 0) begin // Start bit detection
                    busy <= 1;
                    clk_counter <= 0;
                    bit_count <= 0;
                end
            end else begin
                if (clk_counter == SAMPLE_POINT) begin
                    clk_counter <= 0;

                    if (bit_count < 8) begin
                        shift_reg[bit_count] <= rx;
                        bit_count <= bit_count + 1;
                    end else begin
                        data_out <= shift_reg;
                        valid <= 1;
                        busy <= 0;
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
        end
    end
endmodule
