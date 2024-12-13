`timescale 1ns / 1ps

module rs232_tb;
    parameter CLK_FREQ = 50000000; // 50 MHz clock
    parameter BAUD_RATE = 9600;
    parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg clk;
    always #10 clk = ~clk; // 50 MHz clock (20 ns period)

    reg reset;

    // Switches and LEDs for FPGA 1
    reg [7:0] switches_fpga1;
    wire [7:0] leds_fpga1;

    // Switches and LEDs for FPGA 2
    reg [7:0] switches_fpga2;
    wire [7:0] leds_fpga2;

    // UART signals
    wire tx_fpga1, tx_fpga2;
    wire rx_fpga1, rx_fpga2;

    // UART connections
    assign rx_fpga1 = tx_fpga2;
    assign rx_fpga2 = tx_fpga1;

    // Instantiate RS232 modules
    rs232 fpga1 (
        .clk(clk),
        .reset(reset),
        .switches(switches_fpga1),
        .rx(rx_fpga1),
        .tx(tx_fpga1),
        .leds(leds_fpga1)
    );

    rs232 fpga2 (
        .clk(clk),
        .reset(reset),
        .switches(switches_fpga2),
        .rx(rx_fpga2),
        .tx(tx_fpga2),
        .leds(leds_fpga2)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        switches_fpga1 = 8'b00000000;
        switches_fpga2 = 8'b00000000;

        // Reset
        #100;
        reset = 0;

        // Test Case 1: FPGA 1 sends data
        #200;
        switches_fpga1 = 8'b00000001; // Set switch 0
        #BIT_PERIOD * 10;             // Wait for data transfer

        // Test Case 2: FPGA 2 sends data
        #500;
        switches_fpga2 = 8'b11110000; // Set switches 4-7
        #BIT_PERIOD * 10;

        // Test Case 3: Change both FPGAs
        #500;
        switches_fpga1 = 8'b10101010;
        switches_fpga2 = 8'b01010101;
        #BIT_PERIOD * 10;

        $finish;
    end

    initial begin
        $monitor("Time: %t | FPGA1: Switches = %b, LEDs = %b | FPGA2: Switches = %b, LEDs = %b",
                 $time, switches_fpga1, leds_fpga1, switches_fpga2, leds_fpga2);
    end
endmodule
