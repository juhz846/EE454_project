module rs232 (
    input wire clk,           // System clock
    input wire reset,         // Reset signal
    input wire [7:0] switches, // Switch inputs
    input wire rx,            // UART receive line
    output wire tx,           // UART transmit line
    output reg [7:0] leds     // LED outputs
);
    wire ready, valid;
    wire [7:0] received_data;

    // UART Transmitter
    uart_tx transmitter (
        .clk(clk),
        .reset(reset),
        .send(ready),          // Automatically send when ready
        .data_in(switches),    // Send switches' state
        .tx(tx),
        .ready(ready)
    );

    // UART Receiver
    uart_rx receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(received_data),
        .valid(valid)
    );

    // Update LEDs when valid data is received
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            leds <= 8'b0;
        end else if (valid) begin
            leds <= received_data;
        end
    end
endmodule