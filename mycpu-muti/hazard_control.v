`include "define.v"
module hazard_control(
	input wire [`OP_WIDTH - 1:0]    D_epcode_i,
	input wire [`OP_WIDTH - 1:0]	DD_epcode_i,
	input wire [4:0]		D_rs1_i,
	input wire [4:0]		D_rs2_i,
	input wire [4:0]        DD_dstE_i,
	input wire				DD_need_dstE_i,
	input wire 				D_train_taken_i,

	output wire				PC_stall_o,
	output wire				PC_bubble_o,
	output wire				F_stall_o,
	output wire				F_bubble_o,
	output wire				D_stall_o,
	output wire				D_bubble_o,
	output wire 			E_stall_o,
	output wire 			E_bubble_o,
	output wire 			M_stall_o,
	output wire 			M_bubble_o
);
	wire op_load = DD_epcode_i[`op_load];
	wire op_branch = D_epcode_i[`op_branch];
	wire op_jalr = D_epcode_i[`op_jalr];
	assign PC_stall_o = (op_load) & (D_rs1_i == DD_dstE_i | D_rs2_i == DD_dstE_i) &	DD_need_dstE_i;
	assign PC_bubble_o = 0;
	assign F_stall_o = (op_load) & (D_rs1_i == DD_dstE_i | D_rs2_i == DD_dstE_i) &	DD_need_dstE_i;
	assign F_bubble_o = ((op_branch & (~D_train_taken_i)) | op_jalr) & ~(F_stall_o);
	assign D_stall_o = 0;
	assign D_bubble_o = ((op_load) & (D_rs1_i == DD_dstE_i | D_rs2_i == DD_dstE_i) & DD_need_dstE_i);
	assign M_stall_o = 0;
	assign M_bubble_o = 0;
endmodule
