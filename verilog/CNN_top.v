module cnn_top (
    input clk,
    input rst,
    input [7:0] usb_data_in,             // USB input data (pixels or labels)
    input usb_data_valid,                // USB input data valid signal
    input mode_train,                    // 1: Training mode, 0: Inference mode
    output reg [7:0] usb_data_out,       // USB output data (classification result)
    output reg usb_data_ready            // USB output data ready signal
);

    // Parameters
    parameter IMAGE_SIZE = 28;          // MNIST image size
    parameter IMAGE_PIXELS = IMAGE_SIZE * IMAGE_SIZE;
    parameter FC_INPUT_SIZE = 128;      // Fully connected input size
    parameter NUM_CLASSES = 10;        // Number of classes

    // Internal Signals
    reg [7:0] image_buffer[0:IMAGE_PIXELS-1];  // Buffer to store an MNIST image
    reg [7:0] label;                           // Ground truth label (during training)
    reg image_ready;                           // Flag indicating image is ready

    // Convolutional Layer Signals
    wire [15:0] conv_out;                      // Output of Conv2D layer
    reg [7:0] conv_kernel[0:8];                // 3x3 kernel weights for Conv2D
    reg [7:0] conv_bias;                       // Bias for Conv2D layer

    // MaxPooling Layer Signals
    wire [15:0] pool_out;                      // Output of MaxPooling layer

    // FullyConnected Layer Signals
    reg [15:0] fc_weights[0:FC_INPUT_SIZE-1][0:NUM_CLASSES-1]; // FC weights
    reg [15:0] fc_biases[0:NUM_CLASSES-1];     // FC biases
    wire [15:0] fc_out[0:NUM_CLASSES-1];       // FC outputs (logits)

    // Backpropagation Signals
    reg [15:0] learning_rate;                  // Learning rate
    reg [15:0] error[0:NUM_CLASSES-1];         // Error gradients for backpropagation
    wire [15:0] weight_update[0:FC_INPUT_SIZE-1][0:NUM_CLASSES-1]; // Weight updates

    // State Machine States
    typedef enum reg [1:0] {
        IDLE,
        FORWARD_PROP,
        BACKWARD_PROP,
        OUTPUT_RESULTS
    } state_t;

    state_t state;

    // Layer Instantiations
    conv2d conv_layer (
        .clk(clk),
        .rst(rst),
        .pixel_in(image_buffer[0]),  // Simulating the first pixel for simplicity
        .kernel(conv_kernel),
        .bias(conv_bias),
        .conv_out(conv_out)
    );

    maxpool pool_layer (
        .clk(clk),
        .rst(rst),
        .pool_in({conv_out, conv_out, conv_out, conv_out}), // Simulating input for simplicity
        .pool_out(pool_out)
    );

    fully_connected fc_layer (
        .clk(clk),
        .rst(rst),
        .fc_in({pool_out, pool_out}),  // Flattened input for simplicity
        .weights(fc_weights),
        .biases(fc_biases),
        .fc_out(fc_out)
    );

    backpropagation backprop (
        .clk(clk),
        .rst(rst),
        .error(error),
        .fc_in({pool_out, pool_out}),  // Flattened input for simplicity
        .learning_rate(learning_rate),
        .weight_update(weight_update)
    );

    // Control Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            usb_data_out <= 0;
            usb_data_ready <= 0;
            image_ready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (usb_data_valid) begin
                        // Load image data into buffer
                        image_buffer[0] <= usb_data_in; // Simulate loading pixel by pixel
                        if (mode_train) begin
                            label <= usb_data_in; // Last byte received is the label
                        end
                        image_ready <= 1;
                        state <= FORWARD_PROP;
                    end
                end
                FORWARD_PROP: begin
                    // Perform forward propagation
                    if (image_ready) begin
                        // Outputs of the FC layer are now ready
                        if (!mode_train) begin
                            state <= OUTPUT_RESULTS; // Inference mode
                        end else begin
                            state <= BACKWARD_PROP;  // Training mode
                        end
                    end
                end
                BACKWARD_PROP: begin
                    // Perform backward propagation
                    // Compute error gradients (error = fc_out - one-hot(label))
                    // Update weights using backpropagation
                    state <= OUTPUT_RESULTS;
                end
                OUTPUT_RESULTS: begin
                    // Send classification result over USB
                    usb_data_out <= fc_out[0];  // Simplified for one output
                    usb_data_ready <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
