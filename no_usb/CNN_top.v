module cnn_top (
    input clk,
    input rst,
    input [7:0] image_data[0:783],    // Input image (28x28 flattened)
    input [3:0] label,                // Ground truth label
    input start,                      // Start signal to initiate the CNN pipeline
    output reg [7:0] classification,  // Predicted label
    output reg done                   // Processing complete signal
);

    // Parameters
    parameter IMAGE_PIXELS = 784;     // 28x28 image
    parameter FC_INPUT_SIZE = 196;    // 14x14 pooled image
    parameter NUM_CLASSES = 10;       // 10 classes (0-9)

    // Internal Signals
    wire [15:0] conv_out[0:783];      // Convolution layer output
    wire [15:0] pool_out[0:195];      // MaxPooling layer output
    wire [15:0] fc_out[0:9];          // FullyConnected layer output logits
    reg [15:0] one_hot_label[0:9];    // One-hot encoded ground truth label
    reg [15:0] learning_rate;         // Learning rate for training
    wire [15:0] weight_update[0:195][0:9];  // Weight updates (FC layer)
    wire [15:0] bias_update[0:9];          // Bias updates (FC layer)

    // State Machine States
    typedef enum reg [1:0] {
        IDLE,             // Waiting for input
        FORWARD_PROP,     // Forward propagation through the CNN
        BACKWARD_PROP,    // Backpropagation and weight update
        DONE              // Processing complete
    } state_t;

    state_t state;

    // Instantiate CNN Layers
    conv2d conv_layer (
        .clk(clk),
        .rst(rst),
        .image_buffer(image_data),
        .kernel({/* Add your kernel values here */}),
        .bias(8'd0),  // Example bias
        .conv_out(conv_out)
    );

    maxpool pool_layer (
        .clk(clk),
        .rst(rst),
        .conv_out(conv_out),
        .pool_out(pool_out)
    );

    fully_connected fc_layer (
        .clk(clk),
        .rst(rst),
        .fc_in(pool_out),
        .weights({/* Add your weight array initialization */}),
        .biases({/* Add your bias array initialization */}),
        .fc_out(fc_out)
    );

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

    // One-Hot Encoding of the Label
    integer i;
    always @(*) begin
        for (i = 0; i < NUM_CLASSES; i = i + 1) begin
            if (i == label)
                one_hot_label[i] = 16'd1;
            else
                one_hot_label[i] = 16'd0;
        end
    end

    // Control Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            classification <= 0;
            done <= 0;
            learning_rate <= 16'h0001;  // Example fixed-point learning rate (Q4.12 format)
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        done <= 0;
                        state <= FORWARD_PROP;
                    end
                end

                FORWARD_PROP: begin
                    // Simulate forward propagation latency (e.g., pipeline delay)
                    #10;  // Simulate delay
                    classification <= 0;  // Replace this with logic to determine the predicted class
                    state <= BACKWARD_PROP;
                end

                BACKWARD_PROP: begin
                    // Perform backpropagation and update weights (training only)
                    if (start) begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
