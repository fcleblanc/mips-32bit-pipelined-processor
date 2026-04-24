`timescale 1ns / 1ps

// Execution stage datapath.
// Selects forwarded operands when needed, chooses between register/immediate
// ALU input, decodes the ALU control signal, and computes the ALU result.
module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    wire [3:0] ALU_Control;
    wire [31:0] reg1_mux_result;
    wire [31:0] reg2_mux_result;
    wire [31:0] reg_or_imm_mux_result;
    
    assign alu_in2_out = reg2_mux_result;
    
    ALUControl alu_control(
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control));
        
    mux4 reg1_mux(
        .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .sel(Forward_A),
        .y(reg1_mux_result));
        
    mux4 reg2_mux(
        .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .sel(Forward_B),
        .y(reg2_mux_result));
        
    mux2 reg_or_imm(
        .a(reg2_mux_result),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(reg_or_imm_mux_result));
        
    ALU alu(
        .a(reg1_mux_result),
        .b(reg_or_imm_mux_result),
        .alu_control(ALU_Control),
        .alu_result(alu_result));
       
endmodule
