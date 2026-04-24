`timescale 1ns / 1ps

// Instruction Decode stage.
// Decodes the instruction, reads the register file, generates control signals,
// computes branch/jump targets, and inserts a NOP when hazards occur.
module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
     
    wire reg_dst;
    wire branch;
    wire hazard;
    
    // Shift left the lower 26-bits of the instruction by 2 to calculate possible jump address
    assign jump_address = instr[25:0] << 2;
    
    // Branch target = PC+4 + sign-extended immediate shifted left by 2
    assign branch_address = pc_plus4 + (imm_value << 2); 
    
    assign hazard = (!(Data_Hazard)) | Control_Hazard;   
    
    // Branch decision is made in ID by comparing register values directly.
    assign branch_taken = branch & (((reg1^reg2)==32'd0) ? 1'b1: 1'b0); 
    
    wire ctl_reg_dst;
    wire ctl_mem_to_reg;
    wire [1:0] ctl_alu_op;
    wire ctl_mem_read;
    wire ctl_mem_write;
    wire ctl_alu_src;
    wire ctl_reg_write;
    wire[7:0] control_bus_in;
    wire[7:0] control_bus_out;
    wire[7:0] zero_control_bus;
    
    // Combine control signals into a single bus 
    assign control_bus_in[7] = ctl_reg_dst;
    assign control_bus_in[6] = ctl_mem_to_reg;
    assign control_bus_in[5:4] = ctl_alu_op;     // 2 bits for ALU operation
    assign control_bus_in[3] = ctl_mem_read;
    assign control_bus_in[2] = ctl_mem_write;
    assign control_bus_in[1] = ctl_alu_src;
    assign control_bus_in[0] = ctl_reg_write;
    
    // Bus of control signals set to zero
    assign zero_control_bus = 8'b0;
    
    // Split bus into individual signals based on mux result
    assign reg_dst = control_bus_out[7];
    assign mem_to_reg = control_bus_out[6];
    assign alu_op = control_bus_out[5:4];
    assign mem_read = control_bus_out[3];
    assign mem_write = control_bus_out[2];
    assign alu_src = control_bus_out[1];
    assign reg_write = control_bus_out[0];
    
    // Control Module 
    control control_module(
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(ctl_reg_dst),
        .mem_to_reg(ctl_mem_to_reg),
        .alu_op(ctl_alu_op),
        .mem_read(ctl_mem_read),
        .mem_write(ctl_mem_write),
        .alu_src(ctl_alu_src),
        .reg_write(ctl_reg_write),
        .branch(branch),
        .jump(jump));
        
    // Control Signal Mux
    mux2 #(.MUX_WIDTH(8))control_mux(
        .a(control_bus_in),
        .b(zero_control_bus),
        .sel(hazard),
        .y(control_bus_out));
        
    // Sign Extend Unit
    sign_extend SEU(
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value));
        
    // Destination Register Mux
    mux2 #(.MUX_WIDTH(5)) reg_dst_mux(
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg));
        
    // Register File
    register_file reg_file(
        .clk(clk),
        .reset(reset),
        .reg_write_en(mem_wb_reg_write),
        .reg_write_dest(mem_wb_write_reg_addr),
        .reg_write_data(mem_wb_write_back_data),
        .reg_read_addr_1(instr[25:21]),
        .reg_read_addr_2(instr[20:16]),
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2));
        	
       
endmodule
