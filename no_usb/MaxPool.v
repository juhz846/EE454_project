module maxpool (
    input clk,
    input rst,
    input [15:0] conv_out[0:783],      // Input: 28x28 convolved output
    output reg [15:0] pool_out[0:195] // Output: 14x14 pooled output
);
    integer row, col, i, j, idx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (idx = 0; idx < 196; idx = idx + 1)
                pool_out[idx] <= 0;
        end else begin
            // Perform max pooling
            for (row = 0; row < 14; row = row + 1) begin
                for (col = 0; col < 14; col = col + 1) begin
                    idx = row * 14 + col;
                    pool_out[idx] <= conv_out[(row*2) * 28 + (col*2)];
                    for (i = 0; i < 2; i = i + 1) begin
                        for (j = 0; j < 2; j = j + 1) begin
                            pool_out[idx] <= (pool_out[idx] > conv_out[(row*2+i) * 28 + (col*2+j)]) ? pool_out[idx] : conv_out[(row*2+i) * 28 + (col*2+j)];
                        end
                    end
                end
            end
        end
    end
endmodule
