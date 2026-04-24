`timescale 1ns / 1ps

// Parameterized 4-to-1 multiplexer
module mux4 #(parameter MUX_WIDTH = 32)(
    input [MUX_WIDTH-1:0] a,b,c,d,
    input [1:0] sel,
    output [MUX_WIDTH-1:0] y
    );
    
    assign y = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);  
    
    // sel mapping:
    // sel = 00 -> a
    // sel = 01 -> b
    // sel = 10 -> c 
    // sel = 11 -> d
    
endmodule
