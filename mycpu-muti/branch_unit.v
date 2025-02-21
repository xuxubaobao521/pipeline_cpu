module branch_unit(
	input wire [`XLEN - 1:0] 			D_fwdA_i,
	input wire [`XLEN - 1:0] 			D_fwdB_i,
	input wire [`XLEN - 1:0]			D_csr_data_i,
	input wire [`CSR_WIDTH - 1:0]	  	D_csr_op_i,

	input wire [`OP_WIDTH - 1:0]    	FD_epcode_i,
	input wire [`BRANCH_WIDTH - 1:0] 	FD_branch_op_i,
	input wire 							FD_train_predict_i,
	input wire 							FD_train_local_predict_i,
	input wire 							FD_train_global_predict_i,
	input wire [`XLEN - 1:0]         	FD_imme_i,
    input wire [`PC_WIDTH - 1:0]        FD_PC_i,
	input wire [`PC_WIDTH - 1:0]    	FD_nPC_i,

	output wire 						D_train_global_taken_o,
	output wire 						D_train_local_taken_o,
	output wire 						D_train_taken_o,
	
	//写入内存的地址
	//跳转的地址
	output wire [`PC_WIDTH - 1:0]	 	D_nPC_o,
	output wire [`XLEN - 1:0]			D_jmp_o,
	output wire							D_op_jalr_o
);
	wire csr_ecall = D_csr_op_i[`ecall];
	wire csr_mret = D_csr_op_i[`mret];
	wire op_branch = FD_epcode_i[`op_branch];
	wire op_jalr = FD_epcode_i[`op_jalr];
	//BRANCH OP
	wire cout;
	wire [`XLEN - 1:0] sub;
	wire [`XLEN - 1:0] adder_OP1 = D_fwdA_i;
	wire [`XLEN - 1:0] adder_OP2 = {`XLEN{1'b1}} ^ D_fwdB_i;
	assign {cout, sub} = adder_OP1 + adder_OP2 + {{31{1'b0}},1'b1};
	wire branch_eq = FD_branch_op_i[`branch_eq];
	wire branch_ne = FD_branch_op_i[`branch_ne];
	wire branch_lt = FD_branch_op_i[`branch_lt];
	wire branch_ge = FD_branch_op_i[`branch_ge];
	wire branch_ltu = FD_branch_op_i[`branch_ltu];
	wire branch_geu = FD_branch_op_i[`branch_geu];

	wire lt = (D_fwdA_i[`XLEN - 1] & ~D_fwdB_i[`XLEN - 1]) | ((~(D_fwdB_i[`XLEN - 1] ^ D_fwdA_i[`XLEN - 1])) & sub[`XLEN - 1]);
	wire ltu = ~cout;
	wire ne = (|sub);
	wire ge = ~lt;
	wire geu = ~ltu;
	wire eq = ~ne;
	//跳转的的下一个位置
	assign D_train_taken_o =~(((branch_eq & eq) |
				(branch_ne & ne) | 
				(branch_lt & lt) | 
				(branch_ge & ge) | 
				(branch_ltu & ltu) |
				(branch_geu & geu)) ^ FD_train_predict_i);
	assign D_train_local_taken_o =~(((branch_eq & eq) |
				(branch_ne & ne) | 
				(branch_lt & lt) | 
				(branch_ge & ge) | 
				(branch_ltu & ltu) |
				(branch_geu & geu)) ^ FD_train_local_predict_i);
	assign D_train_global_taken_o =~(((branch_eq & eq) | 
				(branch_ne & ne) | 
				(branch_lt & lt) | 
				(branch_ge & ge) | 
				(branch_ltu & ltu) | 
				(branch_geu & geu)) ^ FD_train_global_predict_i);
	wire [`PC_WIDTH - 1 : 0] PC_op1 = (op_jalr) ? D_fwdA_i : FD_PC_i;
	wire [`PC_WIDTH - 1 : 0] PC_op2 = (op_jalr | (op_branch & ~FD_train_predict_i)) ? FD_imme_i : 4;
	assign D_jmp_o = csr_ecall | csr_mret ? D_csr_data_i : PC_op1 + PC_op2;
	assign D_op_jalr_o = op_jalr;
	assign D_nPC_o = (op_branch & ~D_train_taken_o) | op_jalr | csr_ecall | csr_mret ? D_jmp_o : FD_nPC_i;
endmodule
