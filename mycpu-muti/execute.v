`include "define.v"
`define idle 0
`define busy 1

module execute(
	//input
	input wire 						rst,
	input wire						clk_i,
	input wire [`XLEN - 1:0] 		DD_rs1_data_i,
	input wire [`XLEN - 1:0] 		DD_rs2_data_i,
	input wire [`OP_WIDTH - 1:0]    	DD_epcode_i,
	input wire [`BRANCH_WIDTH - 1:0]	DD_branch_op_i,
	input wire [`XLEN - 1:0]         	DD_imme_i,
	input wire [`ALU_WIDTH - 1:0]   	DD_ALU_op_i,
	input wire [`PC_WIDTH - 1:0]    	DD_PC_i,
	//output
	//结果
	output wire [`XLEN - 1:0]		E_valE_o,
	output wire 					E_ready_o
);
	//opcode OP
	wire op_branch = DD_epcode_i[`op_branch];
	wire op_jal = DD_epcode_i[`op_jal];
	wire op_jalr = DD_epcode_i[`op_jalr];
	wire op_store = DD_epcode_i[`op_store];
	wire op_load = DD_epcode_i[`op_load];
	wire op_alur = DD_epcode_i[`op_alur];
	wire op_alurw = DD_epcode_i[`op_alurw];
	wire op_alui = DD_epcode_i[`op_alui];
	wire op_aluiw = DD_epcode_i[`op_aluiw];
	wire op_lui = DD_epcode_i[`op_lui];
	wire op_auipc = DD_epcode_i[`op_auipc];
	//ALU OP
	wire alu_add = DD_ALU_op_i[`alu_add];
	wire alu_sub = DD_ALU_op_i[`alu_sub];
	wire alu_sll = DD_ALU_op_i[`alu_sll];
	wire alu_slt = DD_ALU_op_i[`alu_slt];
	wire alu_sltu = DD_ALU_op_i[`alu_sltu];
	wire alu_xor = DD_ALU_op_i[`alu_xor];
	wire alu_srl = DD_ALU_op_i[`alu_srl];
	wire alu_sra = DD_ALU_op_i[`alu_sra];
	wire alu_or = DD_ALU_op_i[`alu_or];
	wire alu_and = DD_ALU_op_i[`alu_and];
	wire alu_mul = DD_ALU_op_i[`alu_mul];
	wire alu_mulh = DD_ALU_op_i[`alu_mulh];
	wire alu_mulhu = DD_ALU_op_i[`alu_mulhu];
	wire alu_mulhsu = DD_ALU_op_i[`alu_mulhsu];
	wire alu_div = DD_ALU_op_i[`alu_div];
	wire alu_divu = DD_ALU_op_i[`alu_divu];
	wire alu_rem = DD_ALU_op_i[`alu_rem];
	wire alu_remu = DD_ALU_op_i[`alu_remu];
	//BRANCH OP
	wire branch_eq = DD_branch_op_i[`branch_eq];
	wire branch_ne = DD_branch_op_i[`branch_ne];
	wire branch_lt = DD_branch_op_i[`branch_lt];
	wire branch_ge = DD_branch_op_i[`branch_ge];
	wire branch_ltu = DD_branch_op_i[`branch_ltu];
	wire branch_geu = DD_branch_op_i[`branch_geu];
	//ALU计算
	//操作数的选择
	//OP1 : jal/jalr/auipc:DD_PC_i
	//		lui:0
	//		DD_rs1_data_i
	//OP2 : jal/jalr:4
	//		store/load/lui/auipc/alui/aluiw: DD_imme_i
	//      DD_rs2_data_i
	//ADD/SUB
	wire [`XLEN - 1:0] OP1 =  	(op_jal | op_jalr | op_auipc) ? DD_PC_i :
								(op_lui) ? 0 : DD_rs1_data_i;
								
	wire [`XLEN - 1:0] OP2 = 	(op_jal | op_jalr) ? 4 :
								(op_store | op_load | op_lui | op_alui | op_aluiw | op_auipc) ? DD_imme_i : DD_rs2_data_i;
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
	wire sel_mul = alu_mul;
	wire sel_mulh = alu_mulh | alu_mulhsu | alu_mulhu;
	wire sel_div = alu_div;
	wire sel_divu = alu_divu;
	wire sel_rem = alu_rem;
	wire sel_remu = alu_remu;
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
	wire [4:0] shift_OP2 = (op_alurw | op_aluiw) ? {1'b0,OP2[3:0]} : OP2[4:0];
	//sll
	assign res_sll =  OP1 << shift_OP2;
	//srl
	assign res_srl = OP1 >> shift_OP2;
	//sra
	assign res_sra = $signed(OP1) >>> shift_OP2;
	//xor
	assign res_xor = OP1 ^ OP2;
	//and
	assign res_and = OP1 & OP2;
	//or
	assign res_or = OP1 | OP2;
	//mul
	wire [`XLEN:0] smul_OP1 = {OP1[`XLEN - 1], OP1};
	wire [`XLEN:0] smul_OP2 = {OP2[`XLEN - 1], OP2};
	
	wire [`XLEN:0] umul_OP1 = {1'b0, OP1};
	wire [`XLEN:0] umul_OP2 = {1'b0, OP2};

	wire [`XLEN:0] mul_OP1 = alu_mul | alu_mulh | alu_mulhsu ? smul_OP1 : umul_OP1;
	wire [`XLEN:0] mul_OP2 = alu_mul | alu_mulh ? smul_OP2 : umul_OP2;

	//wire [`XLEN * 2 + 1:0]res_mul = $signed(mul_OP1) * $signed(mul_OP2);
	wire [`XLEN * 2 + 1:0] res_mul;
	mul mul(
		.x(mul_OP1),
		.y(mul_OP2),

		.z(res_mul)
	);
	wire need_div = sel_div | sel_divu | sel_rem | sel_remu;
	//div
	wire state;
	wire [5:0] cnt;
	wire sign_rem = OP1[`XLEN - 1];
	wire sign_div = OP1[`XLEN - 1] ^ OP2[`XLEN - 1];
	wire [`XLEN - 1:0]div_OP1 =  OP1[`XLEN - 1] ? (~OP1) + 1 : OP1;
	wire [`XLEN - 1:0]div_OP2 =  OP2[`XLEN - 1] ? (~OP2) + 1 : OP2;
	wire [`XLEN - 1:0]divu_num;
	wire [`XLEN - 1:0]remu_num;
	div div(
		.rst(rst),
		.clk_i(clk_i),
		.need(need_div),
		.Dividend_i(div_OP1),
		.Divisor_i(div_OP2),

		.Q(divu_num),
		.D(remu_num),
		.state_o(state),
		.cnt_o(cnt)
	);
	//ready 全看除法
	assign E_ready_o = (state == `idle & ~need_div) | (state == `busy & ~(|cnt));
	wire [`XLEN - 1:0]div_num = sign_div ? (~divu_num) + 1 : divu_num;
	wire [`XLEN - 1:0]rem_num = sign_rem ? (~remu_num) + 1 : remu_num;


	wire [`XLEN - 1:0]res_div = |OP2 ? (OP1 == {1'b1,31'b0}) & (&OP2) ? OP1 : div_num : {`XLEN{1'b1}};
	wire [`XLEN - 1:0]res_divu = |OP2 ? OP1 / OP2 : {`XLEN{1'b1}};
	//rem
	wire [`XLEN - 1:0]res_rem = |OP2 ? (OP1 == {1'b1,31'b0}) & (&OP2) ? 32'b0 : rem_num : OP1;
	wire [`XLEN - 1:0]res_remu =  |OP2 ? OP1 % OP2 : OP1;
	wire [`XLEN - 1:0] res = 
									({`XLEN{sel_slt}} & res_slt ) | 
									({`XLEN{sel_sltu}} & res_sltu ) | 
									({`XLEN{sel_add | sel_sub}} & res_add_sub ) | 
									({`XLEN{sel_sll}} & res_sll ) | 
									({`XLEN{sel_xor}} & res_xor ) | 
									({`XLEN{sel_srl}} & res_srl ) | 
									({`XLEN{sel_sra}} & res_sra ) | 
									({`XLEN{sel_mul}} & res_mul[`XLEN - 1:0] ) | 
									({`XLEN{sel_mulh}} & res_mul[`XLEN * 2 - 1:`XLEN] ) | 
									({`XLEN{sel_div}} & res_div ) | 
									({`XLEN{sel_divu}} & res_divu ) | 
									({`XLEN{sel_rem}} & res_rem ) | 
									({`XLEN{sel_remu}} & res_remu ) | 
									({`XLEN{sel_or}} & res_or ) | 
									({`XLEN{sel_and}} & res_and );

	wire [`XLEN - 1:0]resw = {res[31:0]};
	assign E_valE_o = (op_alurw | op_aluiw) ? resw : res;
	assign lt = (OP1[`XLEN - 1] & ~OP2[`XLEN - 1]) | ((~(OP2[`XLEN - 1] ^ OP1[`XLEN - 1])) & res_add_sub[`XLEN - 1]);
	assign ltu = ~cout;
endmodule


