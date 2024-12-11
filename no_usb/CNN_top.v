module cnn_top (
    input clk,
    input rst,
    input [8*784-1:0] image_data,    // Flattened 28x28 input image (8 bits per pixel)
    input [3:0] label,               // Ground truth label (4 bits, integer 0-9)
    input start,                     // Signal to start the CNN pipeline
    output reg [3:0] classification, // Predicted label (4 bits, integer 0-9)
    output reg done                  // Signal indicating completion of forward/backpropagation
);

    // Parameters
    parameter IMAGE_PIXELS = 784;    // 28x28 image
    parameter POOL_PIXELS = 196;     // 14x14 pooled image
    parameter NUM_CLASSES = 10;      // Number of output classes

    // Internal Signals
    wire [16*784-1:0] conv_out;         // Flattened 28x28 convolved output
    wire [16*196-1:0] pool_out;         // Flattened 14x14 pooled output
    wire [16*10-1:0] fc_out;            // Flattened FullyConnected output logits
    reg [16*10-1:0] one_hot_label;      // Flattened one-hot encoded label
    wire [16*1960-1:0] weight_update;   // Flattened weight updates (196x10)
    wire [16*10-1:0] bias_update;       // Flattened bias updates (10 classes)

    reg [16*1960-1:0] weights;          // Flattened weights for FullyConnected layer
    reg [16*10-1:0] biases;             // Biases for FullyConnected layer

    // Learning Rate
    reg [15:0] learning_rate = 16'h0010;  // Fixed-point representation (e.g., Q4.12)

    // State Machine
    reg [1:0] state;  // Current state of the state machine
    localparam IDLE          = 2'b00,  // Waiting for input
               FORWARD_PROP  = 2'b01,  // Forward propagation through the CNN
               BACKWARD_PROP = 2'b10,  // Backpropagation and weight updates
               DONE          = 2'b11;  // Processing complete

    // Instantiate Convolution Layer
    conv2d conv_layer (
        .clk(clk),
        .rst(rst),
        .image_buffer(image_data),
        .kernel({8'd1, 8'd0, -8'd1, 8'd1, 8'd0, -8'd1, 8'd1, 8'd0, -8'd1}), // Example kernel
        .bias(8'd0),  // Example bias
        .conv_out(conv_out)
    );

    // Instantiate MaxPooling Layer
    maxpool pool_layer (
        .clk(clk),
        .rst(rst),
        .conv_out(conv_out),
        .pool_out(pool_out)
    );

    // Instantiate Fully Connected Layer
    fully_connected fc_layer (
        .clk(clk),
        .rst(rst),
        .fc_in(pool_out),
        .weights(weights),
        .biases(biases),
        .fc_out(fc_out)
    );

    // Instantiate Backpropagation Module
    backpropagation backprop (
        .clk(clk),
        .rst(rst),
        .fc_out(fc_out),
        .one_hot_label(one_hot_label),
        .fc_in(pool_out),
        .learning_rate(learning_rate),
        .weight_update(weight_update),
        .bias_update(bias_update)
    );

    // Initialize Weights and Biases
    integer i, j;
    initial begin
        // Initialize weights to small random values (for testing)
        for (i = 0; i < 1960; i = i + 1) begin
            weights[i*16 +: 16] = $random % 16; // Small random values
        end
        // Initialize biases to 0
        for (j = 0; j < 10; j = j + 1) begin
            biases[j*16 +: 16] = 16'd0;
        end
    end

    // One-Hot Encoding of Ground Truth Label
    always @(*) begin
        for (i = 0; i < NUM_CLASSES; i = i + 1) begin
            if (i == label)
                one_hot_label[i*16 +: 16] = 16'd1;  // Set one-hot bit for the correct class
            else
                one_hot_label[i*16 +: 16] = 16'd0;  // All other bits are 0
        end
    end

    // Control Logic for State Machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            classification <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        done <= 0;
                        state <= FORWARD_PROP;  // Start forward propagation
                    end
                end

                FORWARD_PROP: begin
                    // Simulate latency for forward propagation (replace with actual pipelined latency if needed)
                    #10;  // Wait for layers to process data

                    // Determine predicted class (argmax on `fc_out`)
                    classification <= 0;
                    for (i = 1; i < NUM_CLASSES; i = i + 1) begin
                        if (fc_out[i*16 +: 16] > fc_out[classification*16 +: 16])
                            classification <= i;
                    end

                    state <= BACKWARD_PROP;
                end

                BACKWARD_PROP: begin
                    // Update weights and biases using backpropagation
                    for (i = 0; i < 1960; i = i + 1) begin
                        weights[i*16 +: 16] <= weights[i*16 +: 16] - weight_update[i*16 +: 16];
                    end
                    for (j = 0; j < 10; j = j + 1) begin
                        biases[j*16 +: 16] <= biases[j*16 +: 16] - bias_update[j*16 +: 16];
                    end

                    state <= DONE;
                end

                DONE: begin
                    done <= 1;
                    state <= IDLE;  // Return to IDLE after completion
                end
            endcase
        end
    end
endmodule
