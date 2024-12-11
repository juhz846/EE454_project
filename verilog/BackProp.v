module backpropagation (
    input clk,
    input rst,
    input [15:0] error[0:9],             // Error gradients
    input [15:0] fc_in[0:127],           // Input to FC layer
    input [15:0] learning_rate,          // Learning rate
    output reg [15:0] weight_update[0:127][0:9] // Weight updates
);
    integer i, j;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 128; i = i + 1)
                for (j = 0; j < 10; j = j + 1)
                    weight_update[i][j] <= 0;
        end else begin
            for (i = 0; i < 128; i = i + 1) begin
                for (j = 0; j < 10; j = j + 1) begin
                    weight_update[i][j] <= learning_rate * error[j] * fc_in[i];
                end
            end
        end
    end
endmodule
