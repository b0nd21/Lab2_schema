`timescale 1ns / 1ps


module substractor(
    input [7:0] a,
    input [7:0] b,
    output [8:0] y
    );
    assign y = a - b;
endmodule