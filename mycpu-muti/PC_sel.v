`include "define.v"
module PC_sel(
	input wire			DD_op_jalr_i,
	input wire			DD_train_vaild_i,
	input wire			DD_train_taken_i,
	input wire 			MD_need_CSR_i,
	input wire[`PC_WIDTH - 1:0]	MD_nPC_i,
	input wire[`PC_WIDTH - 1:0] 	DD_jmp_i,
	
	input wire[`PC_WIDTH - 1:0] 	F_PC_i,
	output wire[`PC_WIDTH - 1:0]	F_sel_PC_o
);
	
	assign F_sel_PC_o = MD_need_CSR_i ? MD_nPC_i : 
						(DD_train_vaild_i & (~DD_train_taken_i)) | DD_op_jalr_i ? DD_jmp_i : F_PC_i;
endmodule
