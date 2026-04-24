`timescale 1ns / 1ps

// ID/EX pipeline register.
// Latches instruction data and control signals from the ID stage and
// forwards them to the EX stage on the next clock cycle.
module pipe_reg #(parameter INST = 32, parameter DEST = 5)(
    input clk, reset,
    input [INST-1:0] if_id_instr,
    input [INST-1:0] reg1,
    input [INST-1:0] reg2,
    input [INST-1:0] imm_value,
    input [DEST-1:0] destination_reg,
    input mem_to_reg,
    input [1:0] alu_op,
    input mem_read,
    input mem_write,
    input alu_src,
    input reg_write,
    output reg [INST-1:0] id_ex_instr,
    output reg [INST-1:0] id_ex_reg1,
    output reg [INST-1:0] id_ex_reg2,
    output reg [INST-1:0] id_ex_imm_value,
    output reg [DEST-1:0] id_ex_destination_reg,
    output reg id_ex_mem_to_reg,
    output reg [1:0] id_ex_alu_op,
    output reg id_ex_mem_read,
    output reg id_ex_mem_write,
    output reg id_ex_alu_src,
    output reg id_ex_reg_write
    );
    
    always @(posedge clk or posedge reset)  
    begin   
        if(reset)   
            begin
            id_ex_instr <= 32'b0;
            id_ex_reg1 <= 32'b0;
            id_ex_reg2 <= 32'b0;
            id_ex_imm_value <= 32'b0;
            id_ex_destination_reg <= 5'b0;
            id_ex_mem_to_reg <= 0;
            id_ex_alu_op <= 2'b0;
            id_ex_mem_read <= 0;
            id_ex_mem_write <= 0;
            id_ex_alu_src <= 0;
            id_ex_reg_write <= 0;
            end
        else 
            begin
            id_ex_instr <= if_id_instr;
            id_ex_reg1 <= reg1;
            id_ex_reg2 <= reg2;
            id_ex_imm_value <= imm_value;
            id_ex_destination_reg <= destination_reg;
            id_ex_mem_to_reg <= mem_to_reg;
            id_ex_alu_op <= alu_op;
            id_ex_mem_read <= mem_read;
            id_ex_mem_write <= mem_write;
            id_ex_alu_src <= alu_src;
            id_ex_reg_write <= reg_write; 
            end  
    end
endmodule




