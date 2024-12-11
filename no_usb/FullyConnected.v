module fully_connected (
    input clk,
    input rst,
    input [16*196-1:0] fc_in,       // Flattened 14x14 pooled input (196 elements, 16 bits each)
    input [16*1960-1:0] weights,   // Flattened 196x10 weights (1960 elements, 16 bits each)
    input [16*10-1:0] biases,      // Biases for 10 classes (10 elements, 16 bits each)
    output reg [16*10-1:0] fc_out   // Flattened output logits (10 elements, 16 bits each)
);
    integer i, j;
    reg [15:0] temp_sum;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 10; i = i + 1)
                fc_out[i*16 +: 16] <= 16'd0;
        end else begin
            for (i = 0; i < 10; i = i + 1) begin
                temp_sum = biases[i*16 +: 16];
                for (j = 0; j < 196; j = j + 1) begin
                    temp_sum = temp_sum + (fc_in[j*16 +: 16] * weights[(i*196 + j)*16 +: 16]);
                end
                fc_out[i*16 +: 16] <= temp_sum;
            end
        end
    end
endmodule
