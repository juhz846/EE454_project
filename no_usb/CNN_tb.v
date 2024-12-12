module cnn_tb;

    // Testbench Signals
    reg clk, rst, start;
    reg [8*784-1:0] image_data;   // Flattened 28x28 image (8 bits per pixel, 784 total)
    reg [3:0] label;              // Ground truth label (integer 0-9)
    wire [3:0] classification;    // Predicted label
    wire done;                    // Processing complete signal

    // Instantiate the `cnn_top` module
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
    always #5 clk = ~clk;  // 10ns clock period

    // Testbench Logic
    integer i;
    reg [7:0] mnist_image[0:783];  // Temporary storage for 28x28 image data
    reg [3:0] mnist_label;         // Temporary storage for label

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        image_data = 0;
        label = 0;

        // Reset the system
        #10 rst = 0;

        // Load a single MNIST example from a text file (or predefined data)
        $readmemb("mnist_data_1.txt", mnist_image); // Load image data into `mnist_image`
        mnist_label = mnist_image[783];          // Extract the label from the last byte
        label = mnist_label;                     // Assign to testbench label signal

        // Flatten the image data into a single vector for `image_data`
        for (i = 0; i < 784; i = i + 1) begin
            image_data[i*8 +: 8] = mnist_image[i];
            $display("mnist_image[%d]: %d", i, mnist_image[i]);

        end

        // Start the CNN pipeline
        start = 1;
        #10 start = 0;

        // Wait for the CNN to complete processing
        wait (done);

        // Display results
        $display("Ground Truth Label: %d", label);
        $display("Predicted Label: %d", classification);

        // Finish simulation
        #20 $finish;
    end
endmodule
