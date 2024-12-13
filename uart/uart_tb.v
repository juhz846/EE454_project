`timescale 1ns / 1ps

module uart_tb;
    // Parameters for simulation
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 50000000; // 50 MHz clock
    parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    // Signals for Transmitter
    reg clk;             // System clock
    reg reset;           // Reset signal
    reg send;            // Trigger to send data
    reg [7:0] data_in;   // Data to be sent
    wire tx;             // Serial output

    // Signals for Receiver
    wire [7:0] data_out; // Received data
    wire valid;          // Data valid flag
    reg rx;              // Serial input for receiver (driven by transmitter)

    // Instantiate UART Transmitter
    uart_tx #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) transmitter (
        .clk(clk),
        .reset(reset),
        .send(send),
        .data_in(data_in),
        .tx(tx),
        .ready() // Ignored in this testbench
    );

    // Instantiate UART Receiver
    uart_rx #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .valid(valid)
    );

    // Clock generation
    always #10 clk = ~clk; // 50 MHz clock (20 ns period)

    // Testbench logic
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        send = 0;
        data_in = 0;
        rx = 1; // RS232 idle state is HIGH

        // Reset the system
        #50;
        reset = 0;

        // Transmit first byte
        #100;
        data_in = 8'hA5; // Example data: 0xA5
        send = 1;
        #20;
        send = 0; // Deassert send after one clock cycle

        // Wait for transmission to complete
        #(BIT_PERIOD * 10); // 10 bits for 8 data bits, 1 start bit, 1 stop bit

        // Transmit second byte
        data_in = 8'h3C; // Example data: 0x3C
        send = 1;
        #20;
        send = 0;

        // Wait for second transmission to complete
        #(BIT_PERIOD * 10);

        // End simulation
        #200;
        $finish;
    end

    // Drive RX with TX
    always @(tx) begin
        rx <= tx;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %t | TX: %b | RX: %b | Received Data: %h | Valid: %b",
                 $time, tx, rx, data_out, valid);
    end
endmodule
