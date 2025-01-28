`include "deDine.v"
module execute(
	//input
	input wire [`XLEN - 1:0] 		 D_rs1_data_i,
	input wire [`XLEN - 1:0] 		 D_rs2_data_i,
	input wire [`OP_WIDTH - 1:0]     D_epcode_i,
	input wire [`BRANCH_WIDTH - 1:0] D_branch_op_i,
	input wire [`XLEN - 1:0]         D_imme_i,
	input wire [`ALU_WIDTH - 1:0]    D_ALU_op_i,
	input wire [`PC_WIDTH - 1:0]     D_PC_i,
	input wire [`PC_WIDTH - 1:0]     D_nPC_i,
	//output
	//结果
	output wire [`XLEN - 1:0]		 E_valE_o,

	//写入内存的地址
	//跳转的地址
	output wire [`PC_WIDTH - 1:0]	 E_nPC_o,
	output wire [`XLEN - 1:0]		 E_jmp_o,
	output wire E_jmp_sel_o
);
	//opcode OP
	wire op_branch = D_epcode_i[`op_branch];
	wire op_jal = D_epcode_i[`op_jal];
	wire op_jalr = D_epcode_i[`op_jalr];
	wire op_store = D_epcode_i[`op_store];
	wire op_load = D_epcode_i[`op_load];
	wire op_alur = D_epcode_i[`op_alur];
	wire op_alurw = D_epcode_i[`op_alurw];
	wire op_alui = D_epcode_i[`op_alui];
	wire op_aluiw = D_epcode_i[`op_aluiw];
	wire op_lui = D_epcode_i[`op_lui];
	wire op_auipc = D_epcode_i[`op_auipc];
	//ALU OP
	wire alu_add = D_ALU_op_i[`alu_add];
	wire alu_sub = D_ALU_op_i[`alu_sub];
	wire alu_sll = D_ALU_op_i[`alu_sll];
	wire alu_slt = D_ALU_op_i[`alu_slt];
	wire alu_sltu = D_ALU_op_i[`alu_sltu];
	wire alu_xor = D_ALU_op_i[`alu_xor];
	wire alu_srl = D_ALU_op_i[`alu_srl];
	wire alu_sra = D_ALU_op_i[`alu_sra];
	wire alu_or = D_ALU_op_i[`alu_or];
	wire alu_and = D_ALU_op_i[`alu_and];
	//BRANCH OP
	wire branch_eq = D_branch_op_i[`branch_eq];
	wire branch_ne = D_branch_op_i[`branch_ne];
	wire branch_lt = D_branch_op_i[`branch_lt];
	wire branch_ge = D_branch_op_i[`branch_ge];
	wire branch_ltu = D_branch_op_i[`branch_ltu];
	wire branch_geu = D_branch_op_i[`branch_geu];
	//ALU计算
	//操作数的选择
	//OP1 : jal/jalr/auipc:D_PC_i
	//		lui:0
	//		D_rs1_data_i
	//OP2 : jal/jalr:4
	//		store/load/lui/auipc/alui/aluiw: D_imme_i
	//      D_rs2_data_i
	//ADD/SUB
	wire [`XLEN - 1:0] OP1 =  	(op_jal | op_jalr | op_auipc) ? D_PC_i :
								(op_lui) ? 0 : D_rs1_data_i;
								
	wire [`XLEN - 1:0] OP2 = 	(op_jal | op_jalr) ? 4 :
								(op_store | op_load | op_lui | op_alui | op_aluiw | op_auipc) ? D_imme_i : D_rs2_data_i;
	//ALU sel
	wire use_sub = alu_sub | alu_slt | alu_sltu | op_branch;
	wire sel_add = alu_add | op_lui | op_auipc | op_store | op_load | op_jal | op_jalr;
	wire sel_sub = alu_sub;
	wire sel_sll = alu_sll;
	wire sel_slt = alu_slt;
	wire sel_sltu = alu_sltu;
	wire sel_xor = alu_xor;
	wire sel_srl = alu_srl;
	wire sel_sra = alu_sra;
	wire sel_or = alu_or;
	wire sel_and = alu_and;
	//res
	wire [`XLEN - 1:0] res_add_sub;
	wire [`XLEN - 1:0] res_sll;
	wire [`XLEN - 1:0] res_slt;
	wire [`XLEN - 1:0] res_sltu;
	wire [`XLEN - 1:0] res_xor;
	wire [`XLEN - 1:0] res_srl;
	wire [`XLEN - 1:0] res_sra;
	wire [`XLEN - 1:0] res_or;
	wire [`XLEN - 1:0] res_and;
	wire [`XLEN - 1:0] res_OP1;
	//sub and ADD
	wire cin = use_sub;
	wire cout;
	wire [`XLEN - 1:0] adder_OP1 = OP1;
	wire [`XLEN - 1:0] adder_OP2 = {`XLEN{use_sub}} ^ OP2;
	assign {cout, res_add_sub} = adder_OP1 + adder_OP2 + {{31{1'b0}},cin};
	
	//slt and sltu
	wire lt, ltu;
	assign res_slt = {31'b0, lt};
	assign res_sltu = {31'b0, ltu};
	//移位
	wire [4:0] shiDt_OP2 = (op_alurw | op_aluiw) ? {1'b0,OP2[3:0]} : OP2[4:0];
	//sll
	assign res_sll =  OP1 << shiDt_OP2;
	//srl
	assign res_srl = OP1 >> shiDt_OP2;
	//sra
	assign res_sra = $signed(OP1) >>> shiDt_OP2;
	//xor
	assign res_xor = OP1 ^ OP2;
	//and
	assign res_and = OP1 & OP2;
	//or
	assign res_or = OP1 | OP2;
	wire [`XLEN - 1:0] res = 
									({`XLEN{sel_slt}} & res_slt ) | 
									({`XLEN{sel_sltu}} & res_sltu ) |
									({`XLEN{sel_add | sel_sub}} & res_add_sub ) |
									({`XLEN{sel_sll}} & res_sll ) | 
									({`XLEN{sel_xor}} & res_xor ) |
									({`XLEN{sel_srl}} & res_srl ) | 
									({`XLEN{sel_sra}} & res_sra ) | 
									({`XLEN{sel_or}} & res_or ) | 
									({`XLEN{sel_and}} & res_and );

	wire [`XLEN - 1:0]resw = {res[31:0]};
	assign E_valE_o = (op_alurw | op_aluiw) ? resw : res;
	
	//lt ltu ge geu eq ne
	// <
	// op1?+ op2?-
	//???? 
	assign lt = (OP1[`XLEN - 1] & ~OP2[`XLEN - 1]) | ((~(OP2[`XLEN - 1] ^ OP1[`XLEN - 1])) & res_add_sub[`XLEN - 1]);
	assign ltu = ~cout;
	wire ne = (|res_add_sub);
	wire ge = ~lt;
	wire geu = ~ltu;
	wire eq = ~ne;
	//跳转的的下一个位置
	wire [`PC_WIDTH - 1 : 0] PC_op1 = (op_jalr) ? D_rs1_data_i : D_PC_i;
	wire [`PC_WIDTH - 1 : 0] PC_op2 = (op_branch) ? 4 : D_imme_i;
	assign E_jmp_o = PC_op1 + PC_op2;
	assign E_jmp_sel_o = 	(branch_eq & ~eq) |
							(branch_ne & ~ne) | 
							(branch_lt & ~lt) |
							(branch_ge & ~ge) | 
							(branch_ltu & ~ltu) |
							(branch_geu & ~geu) | op_jalr;
	assign E_nPC_o = E_jmp_sel_o ? E_jmp_o : D_nPC_i;
endmodule

