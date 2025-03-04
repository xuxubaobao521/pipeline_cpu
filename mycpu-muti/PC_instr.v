`include "define.v"
module PC_instr(
	//input
	input wire								rst,
	input wire 								clk_i,
	input wire [`PC_WIDTH - 1 : 0] 			F_PC_i,
	//output
	output wire								mini_op_branch_o,
	output wire 							mini_op_jal_o,
	output wire [`XLEN - 1:0]				mini_jal_jmp_o,
	output wire [`XLEN - 1:0]				mini_branch_jmp_o,
	output wire 							F_train_vaild_o,
	output wire								F_commit_o,
	output wire [`INSTR_WIDTH - 1 : 0] 		instr_o,
	output wire 							instr_data_ok_o
);
	wire[`OP_WIDTH - 1:0] mini_epcode;
	wire[`XLEN - 1:0] mini_imme;
	//import "DPI-C" function int  instr_dpi_mem_read 	(input int addr  , input int len);
	//icache取指令
	//assign instr_o = instr_dpi_mem_read(F_PC_i, 4);
	icache icache(
		.rst(rst),
		.clk_i(clk_i),
		.instr_addr_i(F_PC_i),
		
		.instr_data_ok_o(instr_data_ok_o),
		.instr_data_o(instr_o)
	);
	//mini-decode
	id mini_decode(
		//input
		.FD_instr_i			(instr_o		),
		//output
		//OP
		.D_epcode_o			(mini_epcode	),
		.D_branch_op_o		(				),
		.D_store_op_o		(				),
		.D_load_op_o		(				),
		.D_ALU_op_o			(				),
		.D_need_dstE_o		(				),
		.D_sel_reg_o		(				),
		.D_csr_read_addr_o	(				),
		.D_csr_op_o			(				),
		.D_csr_addr_o		(				),
		.D_need_CSR_o		(				),
		.D_csr_ecall_o		(				),
		.D_csr_mret_o		(				),
		//data
		.D_rs1_o			(				),
		.D_rs2_o			(				),
		.D_imme_o			(mini_imme		),
		//addr
		.D_dstE_o			(				)
	);
	
	assign mini_op_branch_o = mini_epcode[`op_branch];
	assign mini_op_jal_o = mini_epcode[`op_jal];
	assign F_train_vaild_o = mini_op_branch_o;
	assign mini_jal_jmp_o = mini_imme + F_PC_i;
	assign mini_branch_jmp_o = mini_imme + F_PC_i;
	assign F_commit_o = 1;
endmodule

