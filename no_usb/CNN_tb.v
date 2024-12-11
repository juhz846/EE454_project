module cnn_top_tb;

    // Signals
    reg clk, rst, start;
    reg [7:0] image_data[0:783];    // Input image (28x28 flattened)
    reg [3:0] label;                // Ground truth label
    wire [7:0] classification;      // Predicted label
    wire done;                      // Done signal

    // Instantiate the CNN Top Module
    cnn_top uut (
        .clk(clk),
        .rst(rst),
        .image_data(image_data),
        .label(label),
        .start(start),
        .classification(classification),
        .done(done)
    );

    // Clock Generation
    always #5 clk = ~clk; // Clock period = 10 ns

    // Testbench Logic
    integer i, num_images, num_correct, total_tests;
    reg [7:0] test_image[0:783];    // Temporary storage for an image
    reg [3:0] test_label;           // Temporary storage for a label

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        num_images = 0;
        num_correct = 0;

        // Reset the system
        #10 rst = 0;

        // Open MNIST data file (formatted as one image per line)
        $readmemb("mnist_data.txt", test_image);

        // Test all images
        total_tests = 0;
        for (i = 0; i < 100; i = i + 1) begin  // Adjust the range for the number of images in the file
            // Load test image and label
            label = test_image[783];  // Label is the last byte of the line
            test_image[783] = 0;      // Clear the label from the image buffer
            start = 1;
            #10 start = 0;

            // Wait for CNN processing to complete
            wait (done);

            // Check classification result
            $display("Image #%d: True Label = %d, Predicted Label = %d", i, label, classification);
            if (classification == label) begin
                num_correct = num_correct + 1;
            end
            num_images = num_images + 1;
            total_tests = total_tests + 1;
        end

        // Display final accuracy
        $display("Accuracy: %d/%d (%.2f%%)", num_correct, num_images, (num_correct * 100.0) / num_images);

        // End simulation
        $finish;
    end
endmodule
