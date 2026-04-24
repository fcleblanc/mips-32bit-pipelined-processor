`timescale 1ns / 1ps

// Hazard detection unit for load-use stalls and pipeline flushes.
// Data_Hazard is active low: 0 stalls the pipeline, 1 continues the instruction execution.
module Hazard_detection(
    input id_ex_mem_read,
    input [4:0]id_ex_destination_reg,
    input [4:0] if_id_rs, if_id_rt,
    input branch_taken, jump,
    output reg Data_Hazard,
    output reg IF_Flush
    );
    
    always @(*)  
    begin
        
	   if ((id_ex_mem_read == 1'b1) &
	       ((id_ex_destination_reg == if_id_rs) | (id_ex_destination_reg == if_id_rt)) )
	       Data_Hazard = 1'b0;
	   else
	       Data_Hazard = 1'b1;
	       
               // Flush the fetched instruction when control flow changes.
	       IF_Flush = branch_taken | jump; 
	
    end
endmodule

