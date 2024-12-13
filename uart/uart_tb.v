`timescale 1ns / 1ps

module uart_tb;
    // Clock parameters
    parameter CLK_FREQ = 50000000; // 50 MHz clock
    parameter BAUD_RATE = 9600;
    parameter BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    // Clock generation
    reg clk;
    always #10 clk = ~clk; // 50 MHz clock (20 ns period)

    // Reset signal
    reg reset;

    // Switches and LEDs for FPGA 1
    reg [7:0] switches_fpga1;    // FPGA 1 switch inputs
    wire [7:0] leds_fpga1;       // FPGA 1 LED outputs

    // Switches and LEDs for FPGA 2
    reg [7:0] switches_fpga2;    // FPGA 2 switch inputs
    wire [7:0] leds_fpga2;       // FPGA 2 LED outputs

    // RS232 lines
    wire tx_fpga1, tx_fpga2;
    wire rx_fpga1, rx_fpga2;

    // Assign the UART connections
    assign rx_fpga1 = tx_fpga2; // FPGA 1 receives data sent by FPGA 2
    assign rx_fpga2 = tx_fpga1; // FPGA 2 receives data sent by FPGA 1

    // Instantiate RS232 transfer module for FPGA 1
    uart fpga1 (
        .clk(clk),
        .reset(reset),
        .switches(switches_fpga1),
        .rx(rx_fpga1),
        .tx(tx_fpga1),
        .leds(leds_fpga1)
    );

    // Instantiate RS232 transfer module for FPGA 2
    uart fpga2 (
        .clk(clk),
        .reset(reset),
        .switches(switches_fpga2),
        .rx(rx_fpga2),
        .tx(tx_fpga2),
        .leds(leds_fpga2)
    );

    // Testbench logic
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        switches_fpga1 = 8'b00000000; // All switches off for FPGA 1
        switches_fpga2 = 8'b00000000; // All switches off for FPGA 2

        // Release reset
        #100;
        reset = 0;

        // Test Case 1: Flip a switch on FPGA 1
        #200;
        switches_fpga1 = 8'b00000001; // Turn on Switch 0 of FPGA 1
        #BIT_PERIOD;                 // Wait for data transmission
        #BIT_PERIOD;                 // Allow some extra cycles

        // Test Case 2: Flip multiple switches on FPGA 2
        #500;
        switches_fpga2 = 8'b00001111; // Turn on Switches 0-3 of FPGA 2
        #BIT_PERIOD;                 // Wait for data transmission
        #BIT_PERIOD;                 // Allow some extra cycles

        // Test Case 3: Change switches on both FPGAs
        #500;
        switches_fpga1 = 8'b10101010; // Change switches on FPGA 1
        switches_fpga2 = 8'b01010101; // Change switches on FPGA 2
        #BIT_PERIOD;                 // Wait for data transmission
        #BIT_PERIOD;                 // Allow some extra cycles

        // Test Case 4: Turn off all switches on both FPGAs
        #500;
        switches_fpga1 = 8'b00000000; // All switches off for FPGA 1
        switches_fpga2 = 8'b00000000; // All switches off for FPGA 2
        #BIT_PERIOD;                 // Wait for data transmission

        // End simulation
        #500;
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time: %t | FPGA 1: Switches = %b, LEDs = %b | FPGA 2: Switches = %b, LEDs = %b",
                 $time, switches_fpga1, leds_fpga1, switches_fpga2, leds_fpga2);
    end
endmodule
