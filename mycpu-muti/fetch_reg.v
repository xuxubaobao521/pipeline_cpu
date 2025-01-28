`include "define.v"
module fetch_reg(
	//input
	input wire				rst,
	input wire				clk_i,
	input wire				F_bubble_i,
	input wire				F_stall_i,
	input wire[`INSTR_WIDTH - 1:0]		instr_i,
	input wire[`PC_WIDTH - 1:0]		F_PC_i,
	input wire[`PC_WIDTH - 1:0]		F_nPC_i,
	input wire				F_commit_i,
	//output
	output reg[`INSTR_WIDTH - 1:0]		FD_instr_o,
	output reg[`PC_WIDTH - 1:0]		FD_PC_o,
	output reg[`PC_WIDTH - 1:0]		FD_nPC_o,
	output reg				FD_commit_o
);
	always @(posedge clk_i) begin
		if(F_bubble_i | rst) begin
			FD_instr_o	<=`nop_instr;
			FD_PC_o		<=`nop_PC;
			FD_nPC_o	<=`nop_nPC;
			FD_commit_o 	<=`nop_commit;
		end
		else if(~F_stall_i)begin
			FD_instr_o	<=instr_i;
			FD_PC_o		<=F_PC_i;
			FD_nPC_o	<=F_nPC_i;
			FD_commit_o 	<=F_commit_i;
		end
	end
endmodule
