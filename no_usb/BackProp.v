module backpropagation (
    input clk,
    input rst,
    input [16*10-1:0] fc_out,         // Flattened FC layer output (10 elements, 16 bits each)
    input [16*10-1:0] one_hot_label, // Flattened one-hot encoded label (10 elements, 16 bits each)
    input [16*196-1:0] fc_in,        // Flattened FC input (196 elements, 16 bits each)
    input [15:0] learning_rate,      // Learning rate (single 16-bit value)
    output reg [16*1960-1:0] weight_update, // Flattened weight updates (196x10)
    output reg [16*10-1:0] bias_update      // Bias updates (10 elements, 16 bits each)
);
    integer i, j;
    reg [15:0] temp_error;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 10; i = i + 1) begin
                bias_update[i*16 +: 16] <= 16'd0;
                for (j = 0; j < 196; j = j + 1)
                    weight_update[(i*196 + j)*16 +: 16] <= 16'd0;
            end
        end else begin
            for (i = 0; i < 10; i = i + 1) begin
                temp_error = fc_out[i*16 +: 16] - one_hot_label[i*16 +: 16];
                bias_update[i*16 +: 16] <= learning_rate * temp_error;
                for (j = 0; j < 196; j = j + 1) begin
                    weight_update[(i*196 + j)*16 +: 16] <= learning_rate * temp_error * fc_in[j*16 +: 16];
                end
            end
        end
    end
endmodule
