module Conv2d #(
    parameter WINDOW_SIZE = 3,
    parameter CHANNELS = 1,
    parameter NEURONS = 30
)(
    input wire clk,
    input wire reset,
    input wire [15:0] input_data [0:CHANNELS-1][0:WINDOW_SIZE-1][0:WINDOW_SIZE-1],
    input wire [15:0] kernel [0:CHANNELS-1][0:WINDOW_SIZE-1][0:WINDOW_SIZE-1][0:NEURONS-1],
    output reg [15:0] feature_map [0:NEURONS-1]
);
    integer c, i, j, n;
    reg [31:0] sum;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (n = 0; n < NEURONS; n = n + 1) begin
                feature_map[n] <= 0;
            end
        end else begin
            for (n = 0; n < NEURONS; n = n + 1) begin
                sum = 0;
                for (c = 0; c < CHANNELS; c = c + 1) begin
                    for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
                        for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
                            sum = sum + input_data[c][i][j] * kernel[c][i][j][n];
                        end
                    end
                end
                feature_map[n] <= sum[15:0]; // Truncate to 16 bits
            end
        end
    end
endmodule

module MaxPool #(
    parameter STRIDE = 2,
    parameter INPUT_SIZE = 4
)(
    input wire clk,
    input wire reset,
    input wire [15:0] input_data [0:INPUT_SIZE-1][0:INPUT_SIZE-1],
    output reg [15:0] output_data [0:INPUT_SIZE/STRIDE-1][0:INPUT_SIZE/STRIDE-1]
);
    integer i, j, m, n;
    reg [15:0] max_value;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < INPUT_SIZE/STRIDE; i = i + 1) begin
                for (j = 0; j < INPUT_SIZE/STRIDE; j = j + 1) begin
                    output_data[i][j] <= 0;
                end
            end
        end else begin
            for (i = 0; i < INPUT_SIZE; i = i + STRIDE) begin
                for (j = 0; j < INPUT_SIZE; j = j + STRIDE) begin
                    max_value = input_data[i][j];
                    for (m = 0; m < STRIDE; m = m + 1) begin
                        for (n = 0; n < STRIDE; n = n + 1) begin
                            if (input_data[i+m][j+n] > max_value) begin
                                max_value = input_data[i+m][j+n];
                            end
                        end
                    end
                    output_data[i/STRIDE][j/STRIDE] <= max_value;
                end
            end
        end
    end
endmodule

module FC #(
    parameter INPUT_SIZE = 120,
    parameter OUTPUT_SIZE = 10
)(
    input wire clk,
    input wire reset,
    input wire [15:0] input_vector [0:INPUT_SIZE-1],
    input wire [15:0] weights [0:INPUT_SIZE-1][0:OUTPUT_SIZE-1],
    input wire [15:0] bias [0:OUTPUT_SIZE-1],
    output reg [15:0] output_vector [0:OUTPUT_SIZE-1]
);
    integer i, j;
    reg [31:0] sum;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < OUTPUT_SIZE; i = i + 1) begin
                output_vector[i] <= 0;
            end
        end else begin
            for (i = 0; i < OUTPUT_SIZE; i = i + 1) begin
                sum = bias[i];
                for (j = 0; j < INPUT_SIZE; j = j + 1) begin
                    sum = sum + input_vector[j] * weights[j][i];
                end
                output_vector[i] <= sum[15:0]; // Truncate to 16 bits
            end
        end
    end
endmodule
