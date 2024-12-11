module conv2d (
    input clk,
    input rst,
    input [7:0] image_buffer[0:783],   // Full 28x28 image as input
    input [7:0] kernel[0:8],           // 3x3 kernel
    input [7:0] bias,                  // Bias value
    output reg [15:0] conv_out[0:783]  // 28x28 convolved output
);
    reg [7:0] row_buffer[0:2][0:27];   // 3 rows, 28 pixels each
    integer row, col, kx, ky;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (row = 0; row < 3; row = row + 1)
                for (col = 0; col < 28; col = col + 1)
                    row_buffer[row][col] <= 0;
            for (col = 0; col < 784; col = col + 1)
                conv_out[col] <= 0;
        end else begin
            // Sliding window logic
            for (col = 0; col < 28; col = col + 1) begin
                row_buffer[0][col] <= row_buffer[1][col];
                row_buffer[1][col] <= row_buffer[2][col];
                row_buffer[2][col] <= image_buffer[col + 28 * row];  // Load new row
            end

            // Apply convolution for each pixel
            for (row = 1; row < 27; row = row + 1) begin
                for (col = 1; col < 27; col = col + 1) begin
                    conv_out[row * 28 + col] <=
                        bias +
                        row_buffer[0][col-1] * kernel[0] +
                        row_buffer[0][col]   * kernel[1] +
                        row_buffer[0][col+1] * kernel[2] +
                        row_buffer[1][col-1] * kernel[3] +
                        row_buffer[1][col]   * kernel[4] +
                        row_buffer[1][col+1] * kernel[5] +
                        row_buffer[2][col-1] * kernel[6] +
                        row_buffer[2][col]   * kernel[7] +
                        row_buffer[2][col+1] * kernel[8];
                end
            end
        end
    end
endmodule
