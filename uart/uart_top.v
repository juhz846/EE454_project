module uart_top (
    input wire clk,          // 50 MHz clock
    input wire reset,        // Reset signal
    input wire [7:0] switches, // Data to send
    input wire rx,           // Serial input (from other board)
    output wire tx,          // Serial output (to other board)
    output wire [7:0] leds   // Display received data
);
    wire ready, valid;
    wire [7:0] received_data;

    uart_tx transmitter (
        .clk(clk),
        .reset(reset),
        .send(ready),         // Automatically send
        .data_in(switches),   // Transmit switches value
        .tx(tx),
        .ready(ready)
    );

    uart_rx receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(received_data),
        .valid(valid)
    );

    assign leds = received_data; // Display received data on LEDs
endmodule
