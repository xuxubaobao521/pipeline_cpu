`include "define.v"
module PC_next(
	//input
	input wire[`PC_WIDTH - 1 : 0] 	F_PC_i,	
	input wire[`PC_WIDTH - 1:0] 	mini_jal_jmp_i,
	input wire[`PC_WIDTH - 1:0] 	mini_branch_jmp_i,
	input wire			F_train_predict_i,
	input wire			mini_op_branch_i,
	input wire 			mini_op_jal_i,
	//output
	output wire[`PC_WIDTH - 1 : 0] 	nPC_o
);
	assign nPC_o = 	mini_op_branch_i & F_train_predict_i ? mini_branch_jmp_i :
			mini_op_jal_i ? mini_jal_jmp_i : F_PC_i + 4;
endmodule

