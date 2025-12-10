module nn #(
    parameter int N = 32,
    parameter int W = 16        
)
(
    input  logic        clk,
    input  logic        rst,  
    input  logic signed [N-1:0] in,
    output logic signed [N-1:0] out,
    output logic done
);

    logic signed [N-1:0] l1val[W];
    logic signed [N-1:0] l2val[W];

//    logic [15:0] l1bias[16];
//    logic [15:0] l2bias[16];
//    logic [15:0] outbias;

    // layer 0: 1 -> 16
//    logic [15:0] l1weights[16];        
    // layer 1: 16 -> 16
//    logic [15:0] l2weights[16][16];   
    // layer 2: 16 -> 1
//    logic [15:0] l3weights[16];  
    
logic signed [N-1:0] l1weights [16] = '{
  -325,
  1565,
  -2006,
  -1843 ,
  -1185,
  919,
  -41,
  1994,
  -182,
  744,
  -802,
  -403,
  -2382,
  -1609,
  -819,
  380
};

logic signed [N-1:0] l1bias [16] = '{
  713,  1306, -1009,  -539,   892,  1894,  -421,  1406,
     -330,   275,  1741, -1900,  -776,  -260,  -824,  1739
};

logic signed [N-1:0] l2weights [16][16] = '{
  '{  -581,   102,  -471,  -787,  -596,   739,   228,   583,    27,   110,  -283,  -478,  -641,  -447,   323,   436 },
  '{    -7,  -160,   581,   893,   464,   245,   343,  -395,    95,  -596,  -118,  -264,   590,   602,  -233,   382 },
  '{   399,  -107,  -118,   187,   400,   652,  -395,  -183,   201,   358,   528,   452,   126,  -365,   -17,  -239 },
  '{  -522,   430,   426,  -517,    57,  -154,   -84,  -253,   197,  -303,   144,   259,   367,   175,  -537,  -387 },
  '{    21,   407,  -559,  -426,   265,   552,  -223,   162,  -488,   307,  -616,  -395,  -107,   -70,  -277,   124 },
  '{  -450,   438,   351,  -432,  -165,   -32,    75,    99,   201,    32,  -411,   242,  -491,  -303,  -128,  -324 },
  '{    15,  -560,  -154,   314,  -147,   155,   367,   -69,    14,  -125,   298,   326,   621,   586,   486,   160 },
  '{  -460,  -243,   349,    -3,  -254,  -392,  -479,  -432,  -104,   281,   277,  -494,   319,  -401,  -108,  -208 },
  '{  -319,   120,  -784,  -590,  -260,  -161,  -233,   412,  -461,   201,   242,  -209,   337,    58,  -529,   120 },
  '{   -59,  -229,   409,  -414,    55,  -107,   366,   143,   246,   181,  -123,  -108,  -422,   277,   407,   350 },
  '{  -504,   316,  -429,  -598,  -625,   409,  -305,   283,    22,   664,  -819,  -351,  -586,    88,  -184,   533 },
  '{    14,   318,  -122,  -141,  -116,     0,    -4,   311,  -400,     2,   225,  -416,   -13,   395,   117,  -101 },
  '{  -650,   129,  -365,  -109,  -132,  -225,     6,   304,    64,   366,   137,  -324,   230,  -315,  -217,   -17 },
  '{   169,   384,  -165,     1,   264,  -495,   370,  -423,     7,   -87,  -270,    68,   423,  -150,  -304,  -189 },
  '{  -407,   508,  -246,   140,  -533,   509,   271,   673,   186,   166,  -118,   151,   399,  -489,  -242,   -77 },
  '{  -484,   111,  -287,  -456,   449,  -332,   -58,   147,    16,  -345,  -414,   408,    83,   425,  -172,   151 }
};

logic signed [N-1:0] l2bias [16] = '{
  -316, 208, -229, 122, -47, -100, 79, -316,
   141, -381, 120, -321, -424, 92, -130, 118
};

logic signed [N-1:0] l3weights [16] = '{
  432, -705, -160, 365, 403, -465, -641, -79,
      154, -187, 518, 369, -330, 5, 554, 40
};

    logic signed [N-1:0] outbias = -284;
    logic signed [N-1:0] mat_weights[16][16];
    logic signed [N-1:0] mat_vals[16];
    logic signed [N-1:0] mat_bias[16];
    logic signed [N-1:0] mat_out[16];

    integer i, j;
    
    logic [1:0] layer;
    
    logic mm_done, flag;
    
    mat_mul mm(
        .clk(clk),
        .mat1 (mat_weights),
        .mat2 (mat_vals),
        .bias (mat_bias),
        .out  (mat_out),
        .done (mm_done),
        .flag (flag)
    );
    
    always_ff @(posedge clk) begin
//    always_comb begin
        if(rst) begin
            layer <= 0;
            mm_done <= 0;
        end
        else begin
             mat_vals    <= '{default: 0};
             mat_bias    <= '{default: 0};
             mat_weights <= '{default: 0};
    
            case (layer)
                2'd0: begin
                    $display("layer 0\n");
//                    mat_vals = '{default: 16'h0000, 0: in};
                    mat_vals[0] <= in;
                    mat_bias <= l1bias;
    //                mat_bias = '{default: 16'h0000};
                    for (i = 0; i < W; i+=1) mat_weights[i][0] <= l1weights[i];
    //                mat_weights = '{default: 16'h0000};
                    if(flag==1) mm_done <= 1;
                    if(mm_done) begin
                        if(flag==0) begin
//                            #10;
                            $display("aosjdfoiasfosjofijasfjsafs\n");
//                            l1val <= mat_out;
                            mm_done <= 0;
                            $display("-------------------------------\n");
                            layer <= 2'd1;
                            
                        end
                    end
                end
  
                2'd1: begin
                    $display("layer 1\n");
                    mat_vals    <= l1val;      
                    mat_bias    <= l2bias;     
                    mat_weights <= l2weights;
                    if(flag==1) mm_done <= 1;
                    if(mm_done) begin
                        if(flag==0) begin
//                            #10;
                            mm_done <= 0;
                            layer <= 2'd2;
                            
//                            l2val <= mat_out;
                            
                        end
                    end
                end
                2'd2: begin
                    $display("layer 2\n");
                    mat_vals <= l2val; 
                    mat_bias[0] <= outbias;
//                    mat_weights[0] <= l3weights;
                    for(i = 0; i<W; i+=1) mat_weights[0][i] <= l3weights[i];
                    if(flag==1) begin
//                        #10;
                        mm_done <= 1;
                    end
                    if(mm_done) begin
                        if(flag==0) begin
//                            #10;
                            layer <= 2'd3;
                            mm_done <= 0;
                            done <= 1;
                        end
                    end
                end
    
                2'd3: begin
                    // rst = 1;
                    mm_done <= 1;
                    done <= 1;
//                    out <= mat_out[0];
                end
                default: begin
                
                end
            endcase
        end
    end

    assign l1val = mat_out;
    assign l2val = mat_out;
    
//    assign out = (mat_out[0]+outbias)<0?0:(mat_out[0]+outbias);

    assign out = mat_out[0];    

endmodule
