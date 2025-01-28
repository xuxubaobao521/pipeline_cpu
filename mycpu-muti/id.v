`include "define.v"
module id(
	input wire [`INSTR_WIDTH - 1:0]   FD_instr_i,
	//output
	output wire						  D_sel_reg_o,
	output wire [4:0]                 D_rs1_o,
	output wire [4:0]                 D_rs2_o,
	output wire                       D_need_dstE_o,
	output wire [4:0]                 D_dstE_o,
	output wire [`OP_WIDTH - 1:0]     D_epcode_o,
	output wire [`BRANCH_WIDTH - 1:0] D_branch_op_o,
	output wire [`STORE_WIDTH - 1:0]  D_store_op_o,
	output wire [`LOAD_WIDTH - 1:0]	  D_load_op_o,
	output wire [`XLEN - 1:0]         D_imme_o,
	output wire [`ALU_WIDTH - 1:0]    D_ALU_op_o
);
//指令分解
	wire [6:0] opcode = FD_instr_i[6:0];
	wire [4:0] rd = FD_instr_i[11:7];
	wire [2:0] fun3 = FD_instr_i[14:12];
	wire [4:0] rs1 = FD_instr_i[19:15];
	wire [4:0] rs2 = FD_instr_i[24:20];
	wire [6:0] fun7 = FD_instr_i[31:25];

//设置读寄存器的编号
	assign D_rs1_o = rs1;
	assign D_rs2_o = rs2;
	assign D_dstE_o = rd;
//操作码
	wire op_branch = (opcode == `branch);
	wire op_jal = (opcode == `jal);
	wire op_jalr = (opcode == `jalr);
	wire op_store = (opcode == `store);
	wire op_load = (opcode == `load);
	wire op_alur = (opcode == `alur);
	wire op_alurw = (opcode == `alurw);
	wire op_alui = (opcode == `alui);
	wire op_aluiw = (opcode == `aluiw);
	wire op_lui = (opcode == `lui);
	wire op_auipc = (opcode == `auipc);
	assign D_epcode_o = {
						op_auipc, //11
						op_lui,	//10
						op_aluiw,
						op_alui,
						op_alurw,
						op_alur,
						op_load,
						op_store,
						op_jalr,
						op_jal,
						op_branch
					};
//alu操作
	//reg and i
	wire rv_addi = (op_alui) & (fun3 == `ALU_add);
	wire rv_slti = (op_alui) & (fun3 == `ALU_slt);
	wire rv_sltiu = (op_alui) & (fun3 == `ALU_sltu);
	wire rv_xori = (op_alui) & (fun3 == `ALU_xor);
	wire rv_ori = (op_alui) & (fun3 == `ALU_or);
	wire rv_andi = (op_alui) & (fun3 == `ALU_and);
	wire rv_slli = (op_alui) & (fun3 == `ALU_sll) & (fun7 == 7'b0000000);
	wire rv_srli = (op_alui) & (fun3 == `ALU_srl) & (fun7 == 7'b0000000);
	wire rv_srai = (op_alui) & (fun3 == `ALU_sra) & (fun7 == 7'b0100000);
	wire rv_addiw = (op_aluiw) & (fun3 == `ALU_add);
	wire rv_slliw = (op_aluiw) & (fun3 == `ALU_sll) & (fun7 == 7'b0000000);
	wire rv_srliw = (op_aluiw) & (fun3 == `ALU_srl) & (fun7 == 7'b0000000);
	wire rv_sraiw = (op_aluiw) & (fun3 == `ALU_sra) & (fun7 == 7'b0100000);
	
	//reg and reg
	wire rv_add = (op_alur) & (fun3 == `ALU_add) & (fun7 == 7'b0000000);
	wire rv_sub = (op_alur) & (fun3 == `ALU_sub) & (fun7 == 7'b0100000);
	wire rv_slt = (op_alur) & (fun3 == `ALU_slt);
	wire rv_sltu = (op_alur) & (fun3 == `ALU_sltu);
	wire rv_xor = (op_alur) & (fun3 == `ALU_xor);
	wire rv_sll = (op_alur) & (fun3 == `ALU_sll);
	wire rv_srl = (op_alur) & (fun3 == `ALU_srl) & (fun7 == 7'b0000000);
	wire rv_sra = (op_alur) & (fun3 == `ALU_sra) & (fun7 == 7'b0100000);
	wire rv_or = (op_alur) & (fun3 == `ALU_or);
	wire rv_and = (op_alur) & (fun3 == `ALU_and);
	wire rv_addw = (op_alurw) & (fun3 == `ALU_add) & (fun7 == 7'b0000000);
	wire rv_subw = (op_alurw) & (fun3 == `ALU_sub) & (fun7 == 7'b0100000);
	wire rv_sllw = (op_alur) & (fun3 == `ALU_sll);
	wire rv_srlw = (op_alur) & (fun3 == `ALU_srl) & (fun7 == 7'b0000000);
	wire rv_sraw = (op_alur) & (fun3 == `ALU_sra) & (fun7 == 7'b0100000);
	
	//alu op
	wire ALU_add = rv_addi | rv_add | rv_addw | rv_addiw;
	wire ALU_sub = rv_sub | rv_subw;
	wire ALU_slt = rv_slt | rv_slti;
	wire ALU_sltu = rv_sltu | rv_sltiu;
	wire ALU_xor = rv_xor | rv_xori;
	wire ALU_or = rv_or | rv_ori;
	wire ALU_and = rv_and | rv_andi;
	wire ALU_sll = rv_sll | rv_slli | rv_slliw | rv_sllw;
	wire ALU_sra = rv_sra | rv_srai | rv_sraiw | rv_sraw;
	wire ALU_srl = rv_srl | rv_srli | rv_srliw | rv_srlw;
	
	assign D_ALU_op_o = {
						ALU_and,
						ALU_or,
						ALU_sra,
						ALU_srl,
						ALU_xor,
						ALU_sltu,
						ALU_slt,
						ALU_sll,
						ALU_sub,
						ALU_add
				};
//branch操作
	wire ne = (op_branch) & (fun3 == `ne);
	wire eq = (op_branch) & (fun3 == `eq);
	wire lt = (op_branch) & (fun3 == `lt);
	wire ge = (op_branch) & (fun3 == `ge);
	wire ltu = (op_branch) & (fun3 == `ltu);
	wire geu = (op_branch) & (fun3 == `geu);
	assign D_branch_op_o = {
						geu,
						ltu,
						ge,
						lt,
						ne,
						eq
	};
	
	//不需要 rd操作有
	//store branch
	//并且设置写入寄存器的编号
	assign D_need_dstE_o = (op_jal) | (op_jalr) | (op_load) | (op_alur) | (op_alurw) | (op_alui) | (op_aluiw) | (op_lui) | (op_auipc);
	//立即数
	wire [`XLEN - 1 : 0] I_imme = {{21{FD_instr_i[31]}}, FD_instr_i[30:20]};
	wire [`XLEN - 1 : 0] S_imme = {{21{FD_instr_i[31]}}, FD_instr_i[30:25], FD_instr_i[11:8], FD_instr_i[7]};
	wire [`XLEN - 1 : 0] B_imme = {{20{FD_instr_i[31]}}, FD_instr_i[7], FD_instr_i[30:25], FD_instr_i[11:8], 1'b0};
	wire [`XLEN - 1 : 0] U_imme = {FD_instr_i[31:12], 12'b0};
	wire [`XLEN - 1 : 0] J_imme = {{12{FD_instr_i[31]}}, FD_instr_i[19:12], FD_instr_i[20], FD_instr_i[30:21], 1'b0};
	wire I_type = op_load | op_aluiw | op_alui | op_jalr;
	wire S_type = op_store;
	wire J_type = op_jal;
	wire U_type = op_auipc | op_lui;
	wire B_type = op_branch;
	//选择立即数
	assign D_imme_o = 	({`XLEN{I_type}} & I_imme) |
						({`XLEN{S_type}} & S_imme) |
						({`XLEN{B_type}} & B_imme) |
						({`XLEN{U_type}} & U_imme) |
						({`XLEN{J_type}} & J_imme);
	//store op
	wire sb = op_store & (fun3 == `sb);
	wire sh = op_store & (fun3 == `sh);
	wire sw = op_store & (fun3 == `sw);
	wire sd = op_store & (fun3 == `sd);
	assign D_store_op_o = 	{
								sd,
								sw,
								sh,
								sb
						};
	//load op
	wire lb = op_load & (fun3 == `lb);
	wire lh = op_load & (fun3 == `lh);
	wire lw = op_load & (fun3 == `lw);
	wire ld = op_load & (fun3 == `ld);
	wire lbu = op_load & (fun3 == `lbu);
	wire lhu = op_load & (fun3 == `lhu);
	wire lwu = op_load & (fun3 == `lwu);
	assign D_load_op_o = {
							lwu,
							lhu,
							lbu,
							ld,
							lw,
							lh,
							lb
						};
	//选择内存还是valE
	assign D_sel_reg_o = ~op_load;
endmodule
