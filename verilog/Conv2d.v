module conv2d (
    input clk,
    input rst,
    input [7:0] pixel_in,                // Input pixel
    input [7:0] kernel[0:8],             // Trainable 3x3 kernel weights
    input [7:0] bias,                    // Trainable bias
    output reg [15:0] conv_out           // Output result
);
    reg [7:0] window[0:8];               // 3x3 sliding window
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            conv_out <= 0;
            for (i = 0; i < 9; i = i + 1) begin
                window[i] <= 0;
            end
        end else begin
            // Shift window
            window[0] <= window[1];
            window[1] <= window[2];
            window[2] <= pixel_in;

            // Convolution operation
            conv_out <= bias + 
                        (window[0] * kernel[0]) +
                        (window[1] * kernel[1]) +
                        (window[2] * kernel[2]) +
                        (window[3] * kernel[3]) +
                        (window[4] * kernel[4]) +
                        (window[5] * kernel[5]) +
                        (window[6] * kernel[6]) +
                        (window[7] * kernel[7]) +
                        (window[8] * kernel[8]);
        end
    end
endmodule
