`timescale 1ns / 1ps

// IF/ID pipeline register.
// Latches PC+4 and instruction between the fetch and decode stages.
// Supports enable-based stalls and flush-based insertion of a NOP.
module pipe_reg_en #(parameter ADDR = 10, parameter INSTR = 32)(
    input clk, reset,
    input en, flush,
    input [ADDR-1:0] pc,
    input [INSTR-1:0] instr,
    output reg [ADDR-1:0] pc_out,
    output reg [INSTR-1:0] instr_out
    );
    
    
    always @(posedge clk or posedge reset)  
    begin   
        if(reset || flush)   
            begin
                pc_out <= 0; 
                instr_out <= 0;
            end
        else if (en)
            begin
                pc_out <= pc;
                instr_out <= instr;
            end  
    end  
endmodule