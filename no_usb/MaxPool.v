module maxpool (
    input clk,
    input rst,
    input [16*784-1:0] conv_out,    // Flattened 28x28 input (16 bits per element)
    output reg [16*196-1:0] pool_out // Flattened 14x14 output (16 bits per element)
);
    integer row, col, i, j, pool_idx;
    reg [15:0] temp_max;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (pool_idx = 0; pool_idx < 196; pool_idx = pool_idx + 1)
                pool_out[pool_idx*16 +: 16] <= 16'd0;
        end else begin
            for (row = 0; row < 14; row = row + 1) begin
                for (col = 0; col < 14; col = col + 1) begin
                    pool_idx = row * 14 + col;
                    temp_max = conv_out[(row*2)*28*16 + (col*2)*16 +: 16];
                    for (i = 0; i < 2; i = i + 1) begin
                        for (j = 0; j < 2; j = j + 1) begin
                            temp_max = (temp_max > conv_out[((row*2+i)*28 + (col*2+j))*16 +: 16])
                                       ? temp_max
                                       : conv_out[((row*2+i)*28 + (col*2+j))*16 +: 16];
                        end
                    end
                    pool_out[pool_idx*16 +: 16] <= temp_max;
                end
            end
        end
    end
endmodule
