// module mat_mul #(
//     parameter int N = 16,       
//     parameter int W = 16        
// )(
//     input  logic signed [W-1:0] mat1 [N][N],  
//     input  logic signed [W-1:0] mat2 [N],     
//     input  logic signed [W-1:0] bias [N],     
//     output logic signed [W-1:0] out  [N]      
// );

//     localparam int ACC_W = 2*W + $clog2(N);

//     integer i, j;
//     logic signed [ACC_W-1:0] acc;

//     // always_comb begin
//     always @* begin
//         for (i = 0; i < N; i++) begin
//             acc = '0;
//             for (j = 0; j < N; j++) acc += mat1[i][j] * mat2[j];
//             acc += bias[i];
//             out[i] = acc[W-1:0];
//         end
//     end

// endmodule
module mat_mul #(
    parameter int N = 16,       
    parameter int W = 16        
)(
    input  logic signed [W-1:0] mat1 [N][N],  
    input  logic signed [W-1:0] mat2 [N],     
    input  logic signed [W-1:0] bias [N],     
    output logic signed [W-1:0] out  [N]
);

integer i, j;
logic signed [15:0] mult;
logic signed [15:0] sum;

assign out[0] = 0;

always_comb begin 
    // for(i = 0; i < 16; i ++) begin 
    //     sum = 16'h0000;
    //     for(j = 0; j < 16; j++) begin 
    //         mult = mat1[i][j] * mat2[j];
    //         sum += mult;
    //     end
    //     out[i] = (sum + bias[i]) > 0 ? (sum + bias[i]) : 16'h000;
    // end
    // out[0] = 0;
    // $display("%d\n", out[0]);
end
endmodule 