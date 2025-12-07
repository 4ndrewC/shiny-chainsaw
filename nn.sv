module nn #(
    parameter int N = 200,       
    parameter int W = 16        
)
(
    input  logic        clk,
    input  logic        rst,  
    input  logic [N-1:0] in,
    output logic [N-1:0] out,
    output logic done
);

    logic [N-1:0] l1val[W];
    logic [N-1:0] l2val[W];

//    logic [15:0] l1bias[16];
//    logic [15:0] l2bias[16];
//    logic [15:0] outbias;

    // layer 0: 1 -> 16
//    logic [15:0] l1weights[16];        
    // layer 1: 16 -> 16
//    logic [15:0] l2weights[16][16];   
    // layer 2: 16 -> 1
//    logic [15:0] l3weights[16];  
    
    logic [N-1:0] l1weights [16] = {
      -1301,
      6262,
      -8026,
      -7371,
      -4739,
      3677,
      -162,
      7974,
      -727,
      2975,
       -3207,
      -1610,
      -9529,
      -6438,
      -3275,
      1520 
     };
    
    logic [N-1:0] l1bias [16] = '{
       4558,  1813, -4801,  1318,  3481, 10220, -1686,  3063,
      -1320,  1451,  7963, -7599, -3281,  2349, -4489, 11227
    };
    
    logic [N-1:0] l2weights [16][16] = '{
      '{  1459,  -141,   877, -5902, -5066,  3386,   914,  1648,   108,  -590,   717, -1912,  1931, -8132,  -328,  6257 },
      '{   947, -2987, -3033,    74,  2556,  1362,  1373, -3051,   382, -5635,   310, -1058, -2663,   -51, -8315,  2242 },
      '{  -116,  3984, -5942, -3223,  5535,  8912, -1578,  2125,   805,  5334,   993,  1807, -4931,  -417, -7401,  1027 },
      '{ -2010,  1727,  1433, -2153,   280,  -446,  -337, -1009,   788, -1213,   648,  1036,  1355,   660, -2160, -1430 },
      '{  1581,  1119, -2175, -3655,  -986,  4611,  -893,    59, -1951,   412, -1670, -1580,  -837, -3483, -4590,  2070 },
      '{ -5096,  5431,  1403, -1727, -2619,  1375,   299,  4010,   804,  4000, -5387,   969, -1965, -1214,  -513, -5531 },
      '{  -983, -1759,  -699,   170, -1591,  -365,  1466,  -211,    57,  -177,   154,  1302,  1674,  1030,  1654,  -410 },
      '{ -1840,  -971,  1394,   -13, -1018, -1569, -1917, -1729,  -415,  1123,  1107, -1975,  1278, -1603,  -433,  -830 },
      '{   503,  -282, -3939, -3817, -3125,  1840,  -930,   889, -1843,  -308,  1941,  -835,  1304, -2942, -3346,  2058 },
      '{  -478,  -914,  1402, -1900,   -25,  -669,  1463,   572,   984,   723,  -742,  -431, -1930,   863,  1387,  1152 },
      '{  1100,   924,  4120, -5244, -4613,  2095, -1220,   627,    86,  1883, -1442, -1406,  -464, -5138, -5650,  5805 },
      '{  1810,   953, -4319, -1882, -1673,  2011,   -14,   791, -1602,  -634,  1862, -1662,  -864,  -250, -4314,  1321 },
      '{ -6846,  2882, -1459,  -377,  -594,  -459,    22,  3206,   256,  5723, -2904, -1295,   919, -1228,  -868, -1893 },
      '{   676,  1536,  -659,     3,  1054, -1981,  1481, -1694,    28,  -348, -1079,   271,  1694,  -599, -1216,  -757 },
      '{   270,  1262,  -984, -3510, -4666,  2406,  1085,  2054,   743,  -716,  1460,   605,  1684, -6669,  -969,   936 },
      '{ -1936,   442, -1149, -1826,  1796, -1330,  -233,   587,    65, -1378, -1655,  1632,   333,  1699,  -687,   603 }
    };
    
    logic [N-1:0] l2bias [16] = '{
       3270,  1517,  1206,   590,   380, -4680,  -717, -1262,
       1185, -1768,  4435,  -486, -2529,   368,   341,   472
    };
    
    logic [N-1:0] l3weights [16] = '{
      2888, -5432, -4551,   779,  1991, -3503, -1491,  -316,
         2408,  -746,  2862,  2632, -5501,    20,  2543,   161
    };
    
//    logic [15:0] outbias [16] = '{ -146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};     
    logic [N-1:0] outbias = -1135;
    logic [N-1:0] mat_weights[16][16];
    logic [N-1:0] mat_vals[16];
    logic [N-1:0] mat_bias[16];
    logic [N-1:0] mat_out[16];

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
                    for (i = 0; i < 16; i++) mat_weights[0][i] <= l1weights[i];
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
                            layer <= 2'd2;
                            mm_done <= 0;
//                            l2val <= mat_out;
                            
                        end
                    end
                end
                2'd2: begin
                    $display("layer 2\n");
                    mat_vals <= l2val; 
                    mat_bias <= '{default: 0, 0: outbias};
                    mat_weights[0] <= l3weights;
                    if(flag==1) begin
//                        #10;
                        mm_done <= 1;
                    end
                    if(mm_done) begin
                        if(flag==0) begin
//                            #10;
                            layer <= 2'd3;
                            done <= 1;
                        end
                    end
                end
    
                2'd3: begin
                    // rst = 1;
                end
                default: begin
                
                end
            endcase
        end
    end

    assign l1val = mat_out;
    assign l2val = mat_out;
    
    assign out = mat_out[0];
    

endmodule
