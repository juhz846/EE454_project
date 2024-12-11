module cnn_top_tb;
    // Signals
    reg clk, rst;
    reg [7:0] usb_data_in;
    reg usb_data_valid;
    reg mode_train;
    wire [7:0] usb_data_out;
    wire usb_data_ready;

    // Instantiate the CNN Top Module
    cnn_top uut (
        .clk(clk),
        .rst(rst),
        .usb_data_in(usb_data_in),
        .usb_data_valid(usb_data_valid),
        .mode_train(mode_train),
        .usb_data_out(usb_data_out),
        .usb_data_ready(usb_data_ready)
    );

    // Clock Generation
    always #5 clk = ~clk; // 10 ns clock period

    // Test Sequence
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        usb_data_in = 0;
        usb_data_valid = 0;
        mode_train = 0;

        // Reset
        #10 rst = 0;

        // Send an MNIST image via USB
        mode_train = 0; // Inference mode
        usb_data_valid = 1;
        #10 usb_data_in = 8'd128; // First pixel
        #10 usb_data_in = 8'd64;  // Second pixel
        // Continue sending all pixels...

        usb_data_valid = 0;

        // Wait for results
        #100;

        // Check the classification result
        if (usb_data_ready) begin
            $display("Classification result: %d", usb_data_out);
        end

        // End Simulation
        #500;
        $finish;
    end
endmodule
