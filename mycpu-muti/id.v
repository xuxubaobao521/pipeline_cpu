`include "define.v"
module id(
	input wire [`INSTR_WIDTH - 1:0]   	FD_instr_i,
	//output
	output wire							D_sel_reg_o,
	output wire [4:0]                	D_rs1_o,
	output wire [4:0]                	D_rs2_o,
	output wire                       	D_need_dstE_o,
	output wire [4:0]                 	D_dstE_o,
	output wire [`OP_WIDTH - 1:0]     	D_epcode_o,
	output wire [`BRANCH_WIDTH - 1:0] 	D_branch_op_o,
	output wire [`STORE_WIDTH - 1:0]  	D_store_op_o,
	output wire [`LOAD_WIDTH - 1:0]	  	D_load_op_o,
	output wire [`XLEN - 1:0]         	D_imme_o,
	output wire [`ALU_WIDTH - 1:0]    	D_ALU_op_o,
	output wire 						D_need_CSR_o,
	output wire [`CSR_number_WIDTH - 1:0] D_csr_addr_o,
	output wire [`CSR_number_WIDTH - 1:0] D_csr_read_addr_o,
	output wire 						D_csr_ecall_o,
	output wire							D_csr_mret_o,
	output wire [`CSR_WIDTH - 1:0]	  	D_csr_op_o
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
	wire op_system = (opcode == `system);
	assign D_epcode_o = {
						op_system,
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
	wire rv_andi = (op_alui) & (fun3 == `ALU_and) ;
	wire rv_slli = (op_alui) & (fun3 == `ALU_sll) & (fun7 == 7'b0000000);
	wire rv_srli = (op_alui) & (fun3 == `ALU_srl) & (fun7 == 7'b0000000);
	wire rv_srai = (op_alui) & (fun3 == `ALU_sra) & (fun7 == 7'b0100000);
	wire rv_addiw = (op_aluiw) & (fun3 == `ALU_add) & (fun7 == 7'b0000000);
	wire rv_slliw = (op_aluiw) & (fun3 == `ALU_sll) & (fun7 == 7'b0000000);
	wire rv_srliw = (op_aluiw) & (fun3 == `ALU_srl) & (fun7 == 7'b0000000);
	wire rv_sraiw = (op_aluiw) & (fun3 == `ALU_sra) & (fun7 == 7'b0100000);
	
	//reg and reg
	wire rv_add = (op_alur) & (fun3 == `ALU_add) & (fun7 == 7'b0000000);
	wire rv_sub = (op_alur) & (fun3 == `ALU_sub) & (fun7 == 7'b0100000);
	wire rv_slt = (op_alur) & (fun3 == `ALU_slt) & (fun7 == 7'b0000000);
	wire rv_sltu = (op_alur) & (fun3 == `ALU_sltu) & (fun7 == 7'b0000000);
	wire rv_xor = (op_alur) & (fun3 == `ALU_xor) & (fun7 == 7'b0000000);
	wire rv_sll = (op_alur) & (fun3 == `ALU_sll) & (fun7 == 7'b0000000);
	wire rv_srl = (op_alur) & (fun3 == `ALU_srl) & (fun7 == 7'b0000000);
	wire rv_sra = (op_alur) & (fun3 == `ALU_sra) & (fun7 == 7'b0100000);
	wire rv_or = (op_alur) & (fun3 == `ALU_or) & (fun7 == 7'b0000000);
	wire rv_and = (op_alur) & (fun3 == `ALU_and) & (fun7 == 7'b0000000);
	wire rv_addw = (op_alurw) & (fun3 == `ALU_add) & (fun7 == 7'b0000000);
	wire rv_subw = (op_alurw) & (fun3 == `ALU_sub) & (fun7 == 7'b0100000);
	wire rv_sllw = (op_alur) & (fun3 == `ALU_sll) & (fun7 == 7'b0000000);
	wire rv_srlw = (op_alur) & (fun3 == `ALU_srl) & (fun7 == 7'b0000000);
	wire rv_sraw = (op_alur) & (fun3 == `ALU_sra) & (fun7 == 7'b0100000);
	wire rv_mul = (op_alur) & (fun3 == `ALU_mul) & (fun7 == 7'b0000001);
	wire rv_mulh = (op_alur) & (fun3 == `ALU_mulh) & (fun7 == 7'b0000001);
	wire rv_mulhsu = (op_alur) & (fun3 == `ALU_mulhsu) & (fun7 == 7'b0000001);
	wire rv_mulhu = (op_alur) & (fun3 == `ALU_mulhu) & (fun7 == 7'b0000001);
	wire rv_div = (op_alur) & (fun3 == `ALU_div) & (fun7 == 7'b0000001);
	wire rv_divu = (op_alur) & (fun3 == `ALU_divu) & (fun7 == 7'b0000001);
	wire rv_rem = (op_alur) & (fun3 == `ALU_rem) & (fun7 == 7'b0000001);
	wire rv_remu = (op_alur) & (fun3 == `ALU_remu) & (fun7 == 7'b0000001);
	
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
	wire ALU_mul = rv_mul;
	wire ALU_mulh = rv_mulh;
	wire ALU_mulhu = rv_mulhu;
	wire ALU_mulhsu = rv_mulhsu;
	wire ALU_div = rv_div;
	wire ALU_divu = rv_divu;
	wire ALU_rem = rv_rem;
	wire ALU_remu = rv_remu;
	
	assign D_ALU_op_o = {
						ALU_remu,
						ALU_rem,
						ALU_divu,
						ALU_div,
						ALU_mulhsu,
						ALU_mulhu,
						ALU_mulh,
						ALU_mul,
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
	//立即数
	wire [`XLEN - 1 : 0] I_imme = {{21{FD_instr_i[31]}}, FD_instr_i[30:20]};
	wire [`XLEN - 1 : 0] S_imme = {{21{FD_instr_i[31]}}, FD_instr_i[30:25], FD_instr_i[11:8], FD_instr_i[7]};
	wire [`XLEN - 1 : 0] B_imme = {{20{FD_instr_i[31]}}, FD_instr_i[7], FD_instr_i[30:25], FD_instr_i[11:8], 1'b0};
	wire [`XLEN - 1 : 0] U_imme = {FD_instr_i[31:12], 12'b0};
	wire [`XLEN - 1 : 0] J_imme = {{12{FD_instr_i[31]}}, FD_instr_i[19:12], FD_instr_i[20], FD_instr_i[30:21], 1'b0};
	wire [`XLEN - 1 : 0] csr_imme = {{27{1'b0}}, FD_instr_i[19:15]};
	wire I_type = op_load | op_aluiw | op_alui | op_jalr;
	wire S_type = op_store;
	wire J_type = op_jal;
	wire U_type = op_auipc | op_lui;
	wire B_type = op_branch;
	wire csr_type = op_system;
	//选择立即数
	assign D_imme_o = 	({`XLEN{I_type}} & I_imme) |
						({`XLEN{S_type}} & S_imme) |
						({`XLEN{B_type}} & B_imme) |
						({`XLEN{U_type}} & U_imme) |
						({`XLEN{csr_type}} & csr_imme) |
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
	//csr op
	wire rw = (op_system) & (fun3 == `rw);
	wire rs = (op_system) & (fun3 == `rs);
	wire rc = (op_system) & (fun3 == `rc);
	wire wi = (op_system) & (fun3 == `wi);
	wire si = (op_system) & (fun3 == `si);
	wire ci = (op_system) & (fun3 == `ci);
	wire rv32_ecall = (FD_instr_i == 32'h00000073);
	wire rv32_mret  = (FD_instr_i == 32'h30200073);
	assign D_csr_op_o = {
							rv32_mret,
							rv32_ecall,
							ci,
							si,
							wi,
							rc,
							rs,
							rw
	};
	//csr read and write addr
	assign D_csr_read_addr_o = rv32_ecall ? 12'h305 : 
							rv32_mret ? 12'h341:
							FD_instr_i[31:20];

	assign D_csr_addr_o = 	rv32_ecall ? 12'h341 : 
							FD_instr_i[31:20];
	assign D_csr_ecall_o = rv32_ecall;
	assign D_csr_mret_o	 = rv32_mret;
	//需要写入CSR寄存器的操作
	assign D_need_CSR_o = |D_csr_op_o;
	//不需要 rd操作有
	//store branch
	//并且设置写入寄存器的编号
	assign D_need_dstE_o = (op_jal) | (op_jalr) | (op_load) | (op_alur) | (op_alurw) | (op_alui) | (op_aluiw) | (op_lui) | (op_auipc) | (rw) | (rs) | (rc) | (wi) | (si) | (ci);
endmodule
