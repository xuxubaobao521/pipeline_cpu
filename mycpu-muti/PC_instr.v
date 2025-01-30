`include "define.v"
module PC_instr(
	//input
	input wire [`PC_WIDTH - 1 : 0] 		F_PC_i,
	//output
	output wire				mini_op_branch_o,
	output wire 				mini_op_jal_o,
	output wire [`XLEN - 1:0]		mini_jal_jmp_o,
	output wire [`XLEN - 1:0]		mini_branch_jmp_o,
	output wire 				F_train_vaild_o,
	output wire				F_commit_o,
	output wire [`INSTR_WIDTH - 1 : 0] 	instr_o
);
	wire[`OP_WIDTH - 1:0] mini_epcode;
	wire[`XLEN - 1:0] mini_imme;
	import "DPI-C" function int  dpi_mem_read 	(input int addr  , input int len);
	//取指令
	assign instr_o = dpi_mem_read(F_PC_i, 4);
	//mini-decode
	id mini_decode(
		//input
		.FD_instr_i(instr_o),
		//output
		//OP
		.D_epcode_o(mini_epcode),
		.D_branch_op_o(),
		.D_store_op_o(),
		.D_load_op_o(),
		.D_ALU_op_o(),
		.D_need_dstE_o(),
		.D_sel_reg_o(),
		//data
		.D_rs1_o(),
		.D_rs2_o(),
		.D_imme_o(mini_imme),
		//addr
		.D_dstE_o()
	);
	
	assign mini_op_branch_o = mini_epcode[`op_branch];
	assign mini_op_jal_o = mini_epcode[`op_jal];
	assign F_train_vaild_o = mini_op_branch_o;
	assign mini_jal_jmp_o = mini_imme + F_PC_i;
	assign mini_branch_jmp_o = mini_imme + F_PC_i;
	assign F_commit_o = 1;
endmodule

