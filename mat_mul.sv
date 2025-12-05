module mat_mul (
    input logic signed [15:0] mat1[16][16],
    input logic signed [15:0] mat2[16],
    input logic signed [15:0] bias[16],
    output logic signed [15:0] out[16]
);

integer i, j;
logic signed [15:0] mult;
logic signed [15:0] sum;

always_comb begin 
    for(i = 0; i < 16; i ++) begin 
        sum = 16'h0000;
        for(j = 0; j < 16; j++) begin 
            mult = mat1[1][j] * mat2[j];
            sum += mult;
        end
        out[i] = (sum + bias[i]) > 0 ? (sum + bias[i]) : 16'h000;
    end
end
endmodule 
