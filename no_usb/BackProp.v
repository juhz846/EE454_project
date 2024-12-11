module backpropagation (
    input clk,
    input rst,
    input [15:0] fc_out[0:9],         // FC output logits
    input [15:0] one_hot_label[0:9], // One-hot encoded label
    input [15:0] fc_in[0:195],       // Input to FullyConnected layer
    input [15:0] learning_rate,      // Learning rate
    output reg [15:0] weight_update[0:195][0:9], // Weight updates
    output reg [15:0] bias_update[0:9]           // Bias updates
);
    integer i, j;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 10; i = i + 1) begin
                bias_update[i] <= 0;
                for (j = 0; j < 196; j = j + 1)
                    weight_update[j][i] <= 0;
            end
        end else begin
            // Calculate weight and bias updates
            for (i = 0; i < 10; i = i + 1) begin
                bias_update[i] <= learning_rate * (fc_out[i] - one_hot_label[i]);
                for (j = 0; j < 196; j = j + 1) begin
                    weight_update[j][i] <= learning_rate * (fc_out[i] - one_hot_label[i]) * fc_in[j];
                end
            end
        end
    end
endmodule
