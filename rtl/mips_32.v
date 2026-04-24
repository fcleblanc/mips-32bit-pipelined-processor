`timescale 1ns / 1ps

// Top-level five-stage pipelined MIPS-style processor.
// Instantiates and connects the instruction fetch, decode, execute, memory,
// and writeback stages, along with pipeline registers, hazard detection,
// forwarding, data memory, and writeback selection.
module mips_32(
    input clk, reset,  
    output[31:0] result
    );

// Instruction Fetch

    
    wire [9:0] jump_address;
    wire [9:0] branch_address; 
    wire branch_taken;
    wire jump;
    wire [9:0] pc_plus4;
    wire [31:0] instr;
    
// IF/ID Pipeline Register
    
    wire [9:0] if_id_pc_plus4;
    wire [31:0] if_id_instr;
    
// Instruction Decode
     
    wire [31:0] reg1;
    wire [31:0] reg2;
    wire [31:0] imm_value;
    wire [4:0] destination_reg;
    wire mem_to_reg;
    wire [1:0] alu_op;
    wire mem_read;
    wire mem_write;
    wire alu_src;
    wire reg_write;
    
// ID/EX Pipeline Register
    
    wire [31:0] id_ex_instr;
    wire [31:0] id_ex_reg1;
    wire [31:0] id_ex_reg2;
    wire [31:0] id_ex_imm_value;
    wire [4:0] id_ex_destination_reg;
    wire id_ex_mem_to_reg;
    wire [1:0] id_ex_alu_op;
    wire id_ex_mem_read;
    wire id_ex_mem_write;
    wire id_ex_alu_src;
    wire id_ex_reg_write;
    
// Execute

    wire [31:0] alu_in2_out;
    wire [31:0] alu_result;
    
// EX/MEM Pipeline Register

    wire [31:0] ex_mem_instr;
    wire [4:0] ex_mem_destination_reg;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_alu_in2_out;
    wire ex_mem_mem_to_reg;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_reg_write;
    
// Data Memory
    
    wire [31:0] mem_read_data;
    

// MEM/WB Pipeline Register

    wire [31:0] mem_wb_alu_result;
    wire [31:0] mem_wb_mem_read_data;
    wire mem_wb_mem_to_reg;
    wire mem_wb_reg_write;
    wire [4:0] mem_wb_destination_reg;
    
// Hazard Detection

    wire Data_Hazard;
    wire IF_Flush;
    
// Forwarding Unit

    wire [1:0] Forward_A;
    wire [1:0] Forward_B;
    
// Writeback

    wire [31:0] write_back_data;


// Module Instantiations

// Instruction Fetch   
 
    IF_pipe_stage IF(
        .clk(clk),
        .reset(reset),
        .en(Data_Hazard),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_plus4(pc_plus4),
        .instr(instr));

// IF/ID register
    pipe_reg_en IF_ID(
        .clk(clk),
        .reset(reset),
        .en(Data_Hazard),
        .flush(IF_Flush), 
        .pc(pc_plus4),
        .instr(instr),
        .pc_out(if_id_pc_plus4),
        .instr_out(if_id_instr));
   
// Instruction Decode 
	ID_pipe_stage ID(
	   .clk(clk),
	   .reset(reset),
	   .pc_plus4(if_id_pc_plus4),
	   .instr(if_id_instr),
	   .mem_wb_reg_write(mem_wb_reg_write),
	   .mem_wb_write_reg_addr(mem_wb_destination_reg),
	   .mem_wb_write_back_data(write_back_data),                              
	   .Data_Hazard(Data_Hazard),
	   .Control_Hazard(IF_Flush),
	   .reg1(reg1),
	   .reg2(reg2),
	   .imm_value(imm_value),
	   .branch_address(branch_address),
	   .jump_address(jump_address),
	   .branch_taken(branch_taken),
	   .destination_reg(destination_reg),
	   .mem_to_reg(mem_to_reg),
	   .alu_op(alu_op),
	   .mem_read(mem_read),
	   .mem_write(mem_write),
	   .alu_src(alu_src),
	   .reg_write(reg_write),
	   .jump(jump));
	   

             
// ID/EX registers 
	pipe_reg ID_EX(
	   .clk(clk),
	   .reset(reset),
	   .if_id_instr(if_id_instr), 
	   .reg1(reg1),
	   .reg2(reg2),
	   .imm_value(imm_value),
	   .destination_reg(destination_reg),
	   .mem_to_reg(mem_to_reg),
	   .alu_op(alu_op),
	   .mem_read(mem_read),
	   .mem_write(mem_write),
	   .alu_src(alu_src),
	   .reg_write(reg_write),
	   .id_ex_instr(id_ex_instr),
	   .id_ex_reg1(id_ex_reg1),
	   .id_ex_reg2(id_ex_reg2),
	   .id_ex_imm_value(id_ex_imm_value),
	   .id_ex_destination_reg(id_ex_destination_reg),
	   .id_ex_mem_to_reg(id_ex_mem_to_reg),
	   .id_ex_alu_op(id_ex_alu_op),
	   .id_ex_mem_read(id_ex_mem_read),
	   .id_ex_mem_write(id_ex_mem_write),
	   .id_ex_alu_src(id_ex_alu_src),
	   .id_ex_reg_write(id_ex_reg_write));

// Hazard_detection unit
	Hazard_detection hazard(
	   .id_ex_mem_read(id_ex_mem_read),
	   .id_ex_destination_reg(id_ex_destination_reg),
	   .if_id_rs(if_id_instr[25:21]),
	   .if_id_rt(if_id_instr[20:16]),
	   .branch_taken(branch_taken),
	   .jump(jump),
	   .Data_Hazard(Data_Hazard),
	   .IF_Flush(IF_Flush));
	   
           
// Execution    
	EX_pipe_stage EX(
	   .id_ex_instr(id_ex_instr),
	   .reg1(id_ex_reg1),
	   .reg2(id_ex_reg2),
	   .id_ex_imm_value(id_ex_imm_value),
	   .ex_mem_alu_result(ex_mem_alu_result),
	   .mem_wb_write_back_result(write_back_data),              
	   .id_ex_alu_src(id_ex_alu_src),
	   .id_ex_alu_op(id_ex_alu_op),
	   .Forward_A(Forward_A),
	   .Forward_B(Forward_B),
	   .alu_in2_out(alu_in2_out),
	   .alu_result(alu_result));
        
// Forwarding unit
	EX_Forwarding_unit Forward(
	   .ex_mem_reg_write(ex_mem_reg_write),
	   .ex_mem_write_reg_addr(ex_mem_destination_reg),
	   .id_ex_instr_rs(id_ex_instr[25:21]),
	   .id_ex_instr_rt(id_ex_instr[20:16]),
	   .mem_wb_reg_write(mem_wb_reg_write),
	   .mem_wb_write_reg_addr(mem_wb_destination_reg),
	   .Forward_A(Forward_A),
	   .Forward_B(Forward_B));

     
// EX/MEM registers
// Reuse pipe_reg to latch EX/MEM signals; port names reflect the original ID/EX use
	pipe_reg EX_MEM(
	   .clk(clk),
	   .reset(reset),
	   .if_id_instr(id_ex_instr),  
	   .destination_reg(id_ex_destination_reg), 
	   .reg1(alu_result), 
	   .reg2(alu_in2_out), 
       .mem_to_reg(id_ex_mem_to_reg), 
       .mem_read(id_ex_mem_read), 
       .mem_write(id_ex_mem_write), 
       .reg_write(id_ex_reg_write), 
       .id_ex_instr(ex_mem_instr), 
       .id_ex_destination_reg(ex_mem_destination_reg), 
       .id_ex_reg1(ex_mem_alu_result), 
       .id_ex_reg2(ex_mem_alu_in2_out), 
       .id_ex_mem_to_reg(ex_mem_mem_to_reg), 
       .id_ex_mem_read(ex_mem_mem_read), 
       .id_ex_mem_write(ex_mem_mem_write), 
       .id_ex_reg_write(ex_mem_reg_write)); 
    
// Data memory    
	
	data_memory data_mem(
	   .clk(clk),
	   .mem_access_addr(ex_mem_alu_result),
	   .mem_write_data(ex_mem_alu_in2_out),
	   .mem_write_en(ex_mem_mem_write),
	   .mem_read_en(ex_mem_mem_read),
	   .mem_read_data(mem_read_data));
     

// MEM/WB registers  
// Reuse pipe_reg to latch MEM/WB signals; port names reflect the original ID/EX use.
	
	pipe_reg MEM_WB(
	   .clk(clk),
	   .reset(reset),
	   .if_id_instr(ex_mem_alu_result), 
	   .reg1(mem_read_data), 
	   .mem_to_reg(ex_mem_mem_to_reg), 
	   .reg_write(ex_mem_reg_write), 
	   .destination_reg(ex_mem_destination_reg), 
	   .id_ex_instr(mem_wb_alu_result), 
	   .id_ex_reg1(mem_wb_mem_read_data), 
	   .id_ex_mem_to_reg(mem_wb_mem_to_reg), 
	   .id_ex_reg_write(mem_wb_reg_write), 
	   .id_ex_destination_reg(mem_wb_destination_reg)); 
    

// Writeback    
	
	mux2 WB(
	   .a(mem_wb_alu_result),
	   .b(mem_wb_mem_read_data),
	   .sel(mem_wb_mem_to_reg),
	   .y(write_back_data));
	   
        assign result = write_back_data;
    
endmodule
