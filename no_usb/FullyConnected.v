module fully_connected (
    input clk,
    input rst,
    input [15:0] fc_in[0:195],         // Input: Flattened 14x14 pooled output
    input [15:0] weights[0:195][0:9], // Weights for each class
    input [15:0] biases[0:9],         // Biases for each class
    output reg [15:0] fc_out[0:9]     // Output: Logits for each class
);
    integer i, j;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 10; i = i + 1)
                fc_out[i] <= 0;
        end else begin
            for (i = 0; i < 10; i = i + 1) begin
                fc_out[i] <= biases[i];
                for (j = 0; j < 196; j = j + 1) begin
                    fc_out[i] <= fc_out[i] + (fc_in[j] * weights[j][i]);
                end
            end
        end
    end
endmodule
