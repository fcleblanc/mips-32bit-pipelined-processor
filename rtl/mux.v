`timescale 1ns / 1ps

// Parameterized 2-to-1 multiplexer
module mux2 #(parameter MUX_WIDTH = 32)
(   input [MUX_WIDTH-1:0] a,b,
    input sel,
    output [MUX_WIDTH-1:0] y
    );
    
    assign y = sel ? b : a;

endmodule
