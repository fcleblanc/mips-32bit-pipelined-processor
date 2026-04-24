`timescale 1ns / 1ps

// Instruction Fetch stage.
// Maintains the program counter, fetches the current instruction, computes
// PC+4, and selects the next PC from sequential, branch, or jump targets.
module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
wire [9:0] mux1_result;
wire [9:0] mux2_result;
reg [9:0] pc;
    

// Select branch target when a branch is taken; otherwise use PC+4.
mux2 pc_or_branch(
    .a(pc_plus4),
    .b(branch_address),
    .sel(branch_taken), 
    .y(mux1_result));

// Jump target has final priority over branch/sequential PC.
mux2 jump_mux(
    .a(mux1_result),
    .b(jump_address),
    .sel(jump),
    .y(mux2_result));

// Instruction memory
instruction_mem inst_mem(
    .read_addr(pc),
    .data(instr));

// Increment the program counter
assign pc_plus4 = pc + 10'd4;

// Update PC only when enabled; holding PC implements a fetch-stage stall.
always@(posedge clk or posedge reset)
begin
    if(reset)
        begin
            pc <= 10'b0;
        end
    else if(en == 1)
        begin
            pc <= mux2_result;
        end
end
    
endmodule
