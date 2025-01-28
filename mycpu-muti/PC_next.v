`include "define.v"
module PC_next(
	//input
	input wire[`PC_WIDTH - 1 : 0] F_PC_i,	
	input wire					mini_jmp_sel_i,
	input wire[`PC_WIDTH - 1:0] mini_jmp_i,
	//output
	output wire[`PC_WIDTH - 1 : 0] nPC_o
);
	assign nPC_o = mini_jmp_sel_i ? mini_jmp_i : F_PC_i + 4;
endmodule
