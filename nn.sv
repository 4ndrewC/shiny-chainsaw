module nn #(
    parameter int N = 40,       
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
    
logic [N-1:0] l1weights [16] = '{
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
   2853,  5223, -4035, -2156,  3570,  7577, -1686,  5625,
  -1320,  1102,  6963, -7599, -3103, -1040, -3295,  6956
};

logic [N-1:0] l2weights [16][16] = '{
  '{ -2325,   407, -1884, -3147, -2384,  2954,   914,  2333,   108,   441, -1131, -1912, -2563, -1789,  1292,  1744 },
  '{   -29,  -638,  2324,  3572,  1858,   981,  1373, -1581,   382, -2382,  -470, -1058,  2360,  2407,  -934,  1530 },
  '{  1595,  -428,  -470,   746,  1602,  2610, -1578,  -732,   805,  1433,  2113,  1807,   503, -1459,   -66,  -957 },
  '{ -2089,  1718,  1703, -2068,   229,  -617,  -337, -1013,   788, -1213,   575,  1036,  1469,   702, -2149, -1548 },
  '{    83,  1627, -2235, -1702,  1059,  2210,  -893,   649, -1951,  1230, -2465, -1580,  -428,  -279, -1108,   496 },
  '{ -1799,  1752,  1403, -1727,  -659,  -130,   299,   397,   804,   126, -1645,   969, -1965, -1214,  -513, -1296 },
  '{    58, -2239,  -616,  1257,  -587,   622,  1466,  -277,    57,  -498,  1191,  1302,  2484,  2342,  1944,   638 },
  '{ -1840,  -971,  1394,   -13, -1018, -1569, -1917, -1729,  -415,  1123,  1107, -1975,  1278, -1603,  -433,  -830 },
  '{ -1276,   479, -3135, -2359, -1042,  -644,  -930,  1647, -1843,   802,   966,  -835,  1350,   233, -2116,   478 },
  '{  -236,  -914,  1638, -1655,   220,  -429,  1463,   572,   984,   723,  -492,  -431, -1688,  1110,  1626,  1401 },
  '{ -2016,  1265, -1716, -2392, -2499,  1638, -1220,  1132,    86,  2655, -3275, -1406, -2344,   352,  -736,  2132 },
  '{    57,  1274,  -490,  -566,  -465,     1,   -14,  1245, -1602,     8,   901, -1662,   -51,  1581,   468,  -404 },
  '{ -2600,   518, -1459,  -436,  -528,  -902,    22,  1214,   256,  1465,   549, -1295,   919, -1260,  -868,   -67 },
  '{   676,  1536,  -659,     3,  1054, -1981,  1481, -1694,    28,  -348, -1079,   271,  1694,  -599, -1216,  -757 },
  '{ -1629,  2032,  -984,   561, -2134,  2034,  1085,  2691,   743,   666,  -470,   605,  1595, -1958,  -969,  -309 },
  '{ -1936,   442, -1149, -1826,  1796, -1330,  -233,   587,    65, -1378, -1655,  1632,   333,  1699,  -687,   603 }
};

logic [N-1:0] l2bias [16] = '{
  -1263,   834,  -916,   489,  -186,  -402,   314, -1262,
    565, -1525,   481, -1285, -1697,   368,  -520,   472
};

logic [N-1:0] l3weights [16] = '{
  1727, -2821,  -641,  1459,  1611, -1859, -2564,  -316,
   614,  -747,  2071,  1475, -1322,    20,  2218,   161
};

    logic [N-1:0] outbias = -1136;
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
                    for (i = 0; i < 16; i++) mat_weights[i][0] <= l1weights[i];
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
