module nn(
    input  logic        clk,
    input  logic [2:0]  layer,  
    input  logic [15:0] in,
    output logic [15:0] out
);

    logic [15:0] l1val[16];
    logic [15:0] l2val[16];

    logic [15:0] l1bias[16];
    logic [15:0] l2bias[16];
    logic [15:0] outbias;

    // layer 0: 1 -> 16
    logic [15:0] l1weights[16];        
    // layer 1: 16 -> 16
    logic [15:0] l2weights[16][16];   
    // layer 2: 16 -> 1
    logic [15:0] l3weights[16];        

    logic [15:0] mat_weights[16][16];
    logic [15:0] mat_vals[16];
    logic [15:0] mat_bias[16];
    logic [15:0] mat_out[16];

    integer i, j;

    always_comb begin
        // mat_vals    = '{default: 16'h0000};
        // mat_bias    = '{default: 16'h0000};
        // mat_weights = '{default: 16'h0000};
        for (i = 0; i < 16; i++)
        for (j = 0; j < 16; j++)
            mat_weights[i][j] = 16'h0000;
        case (layer)
            3'd0: begin
                mat_vals = '{default: 16'h0000, 0: in};
                mat_bias = l1bias;
                for (i = 0; i < 16; i++) mat_weights[i][0] = l1weights[i];
            end

            3'd1: begin
                mat_vals    = l1val;      
                mat_bias    = l2bias;     
                mat_weights = l2weights;  
            end
            3'd2: begin
                mat_vals = l2val; 
                mat_bias = '{default: 16'h0000, 0: outbias};
                mat_weights[0] = l3weights;
            end

            default: begin

            end
        endcase
    end

    mat_mul mm(
        .mat1 (mat_weights),
        .mat2 (mat_vals),
        .bias (mat_bias),
        .out  (mat_out)
    );

    assign out = mat_out[0];

endmodule
