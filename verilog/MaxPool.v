module maxpool (
    input clk,
    input rst,
    input [15:0] pool_in[0:3],          // Input pixels (2x2 window)
    output reg [15:0] pool_out          // Max value output
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pool_out <= 0;
        end else begin
            pool_out <= (pool_in[0] > pool_in[1]) ? 
                        ((pool_in[0] > pool_in[2]) ? 
                            ((pool_in[0] > pool_in[3]) ? pool_in[0] : pool_in[3]) : 
                            ((pool_in[2] > pool_in[3]) ? pool_in[2] : pool_in[3])) : 
                        ((pool_in[1] > pool_in[2]) ? 
                            ((pool_in[1] > pool_in[3]) ? pool_in[1] : pool_in[3]) : 
                            ((pool_in[2] > pool_in[3]) ? pool_in[2] : pool_in[3]));
        end
    end
endmodule
