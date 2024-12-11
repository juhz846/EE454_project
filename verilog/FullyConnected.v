module fully_connected (
    input clk,
    input rst,
    input [15:0] fc_in[0:127],          // Flattened input vector
    input [15:0] weights[0:127][0:9],  // Trainable weights (128x10)
    input [15:0] biases[0:9],          // Trainable biases (1x10)
    output reg [15:0] fc_out[0:9]      // Output logits for 10 classes
);
    integer i, j;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 10; i = i + 1)
                fc_out[i] <= 0;
        end else begin
            for (i = 0; i < 10; i = i + 1) begin
                fc_out[i] <= biases[i];
                for (j = 0; j < 128; j = j + 1) begin
                    fc_out[i] <= fc_out[i] + (fc_in[j] * weights[j][i]);
                end
            end
        end
    end
endmodule
