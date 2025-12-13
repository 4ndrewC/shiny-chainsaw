`timescale 1 ps / 1 ps

module mb_block_wrapper
   (input logic Clk,
//    input logic [15:0] nn_out,
    input logic reset_rtl_0,
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd);
//  input clk_100MHz;
//    input Clk;
//  input [15:0]nn_out;
//  input reset_rtl_0;
//  input uart_rtl_0_rxd;
//  output uart_rtl_0_txd;

//  wire clk_100MHz;
//  wire [15:0]nn_out;
//  wire reset_rtl_0;
//  wire uart_rtl_0_rxd;
//  wire uart_rtl_0_txd;
  
//  assign nn_out = 3;
    logic [15:0] nn_out;
//    assign nn_out = 10;
  mb_block mb_block_i
       (.clk_100MHz(Clk),
        .nn_out(nn_out),
        .reset_rtl_0(~reset_rtl_0),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd));
        
        
//   input  logic		clk, 
//	input  logic 		reset,
//	input  logic signed [15:0] in,
//    output logic signed [N-1:0] out
    logic signed [15:0] in;
//    assign in = 16'sd614
    logic [15:0] counter = 0;
    always_ff @(posedge Clk) begin
        if(reset_rtl_0) begin
             in <= 16'sd0;
             counter = 0;
        end
        else begin
            counter <= counter+1;
            if(counter==1000) begin
                in <= in+1;
                if(in >= 12867) begin 
                    in <= 16'sd0;
                end
                counter <= 0;
            end
            
        end
    end
   processor_top nn(
    .clk(Clk),
    .reset(reset_rtl_0),
    .in(in),
    .out(nn_out)
   );
endmodule
