`timescale 1ns/1ps

module tb_mat_mul;

    localparam int N = 16;
    localparam int W = 16;

    logic signed [W-1:0] mat1 [N][N];
    logic signed [W-1:0] mat2 [N];
    logic signed [W-1:0] bias [N];
    logic signed [W-1:0] out  [N];

    int i, j;

    // Instantiate your DUT
    mat_mul #(.N(N), .W(W)) dut (
        .mat1(mat1),
        .mat2(mat2),
        .bias(bias),
        .out(out)
    );

    initial begin
        // -------------------------------
        // Set ALL inputs to zero
        // -------------------------------
        for (i = 0; i < N; i++) begin
            mat2[i] = 0;
            bias[i] = 0;
            for (j = 0; j < N; j++) begin
                mat1[i][j] = 0;
            end
        end

        #1000; // allow combinational logic to settle

        // -------------------------------
        // MANUALLY CHECK ALL OUTPUTS
        // -------------------------------
        $display("%d\n", out[0]);

        for (i = 0; i < N; i++) begin
            if (out[i] !== 0) begin
                $display("ERROR: out[%0d] should be 0, got %0d", i, out[i]);
                $fatal;
            end
        end

        #1000;

        $display("PASS: All-zero matrix multiplication test succeeded.");
        $finish;
    end

endmodule
