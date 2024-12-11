module conv2d (
    input clk,
    input rst,
    input [8*784-1:0] image_buffer, // Flattened 28x28 image (784 pixels, each 8 bits)
    input [8*9-1:0] kernel,         // Flattened 3x3 kernel (9 elements, each 8 bits)
    input [7:0] bias,               // Single bias value
    output reg [16*784-1:0] conv_out // Flattened 28x28 output (784 elements, each 16 bits)
);
    integer row, col, kx, ky, pixel_idx;
    reg [7:0] window[0:8];
    reg [15:0] temp_sum;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (pixel_idx = 0; pixel_idx < 784; pixel_idx = pixel_idx + 1)
                conv_out[pixel_idx*16 +: 16] <= 16'd0;
        end else begin
            for (row = 1; row < 27; row = row + 1) begin
                for (col = 1; col < 27; col = col + 1) begin
                    temp_sum = bias;
                    for (ky = -1; ky <= 1; ky = ky + 1) begin
                        for (kx = -1; kx <= 1; kx = kx + 1) begin
                            window[(ky+1)*3 + (kx+1)] = image_buffer[((row+ky)*28 + (col+kx))*8 +: 8];
                            temp_sum = temp_sum + (window[(ky+1)*3 + (kx+1)] * kernel[((ky+1)*3 + (kx+1))*8 +: 8]);
                        end
                    end
                    conv_out[(row*28 + col)*16 +: 16] <= temp_sum;
                end
            end
        end
    end
endmodule
