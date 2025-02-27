`include "define.v"
module decode_reg(
	//input
	input wire							rst,
	input wire							clk_i,
	input wire [`OP_WIDTH - 1:0]     	D_epcode_i,
	input wire [`STORE_WIDTH - 1:0]  	D_store_op_i,
	input wire [`LOAD_WIDTH - 1:0]   	D_load_op_i,
	input wire [`BRANCH_WIDTH - 1:0] 	D_branch_op_i,
	input wire [`ALU_WIDTH - 1:0]    	D_ALU_op_i,
	input wire							D_sel_reg_i,
	input wire [`PC_WIDTH - 1:0]     	D_PC_i,
	input wire [`PC_WIDTH - 1:0]		D_nPC_i,
	input wire                       	D_need_dstE_i,
	input wire [4:0]                 	D_dstE_i,
	input wire [`XLEN - 1:0]			D_rs1_data_i,
	input wire [`XLEN - 1:0]			D_rs2_data_i,
	input wire [`XLEN - 1:0] 			D_imme_i,
	input wire 							D_commit_i,
	input wire [`INSTR_WIDTH - 1:0]		D_instr_i,
	input wire							D_train_predict_i,
	input wire 							D_train_vaild_i,
	input wire [`history_WIDTH - 1:0] 	D_train_global_history_i,
	input wire 							D_train_global_predict_i,
	input wire							D_train_local_predict_i,
	input wire							D_success_hit_i,
	input wire							D_jal_i,
	input wire							D_train_taken_i,
	input wire							D_train_global_taken_i,
	input wire							D_train_local_taken_i,
	input wire							D_op_jalr_i,
	input wire [`PC_WIDTH - 1:0]    	D_jmp_i,
	input wire 							decode_control_i,
	input wire							decode_ready_i,
	input wire							execute_allow_in_i,
	input wire 							D_need_CSR_i,
	input wire [`CSR_number_WIDTH - 1:0]D_csr_addr_i,
	input wire [`CSR_WIDTH - 1:0]	  	D_csr_op_i,
	input wire [`XLEN - 1:0]			D_csr_data_i,
	input wire 							D_csr_ecall_i,
	input wire  						D_csr_mret_i,
	//output
	output reg 							DD_csr_ecall_o,
	output reg  						DD_csr_mret_o,
	output reg [`XLEN - 1:0]			DD_csr_data_o,
	output reg 							DD_need_CSR_o,
	output reg [`CSR_number_WIDTH - 1:0]DD_csr_addr_o,
	output reg [`CSR_WIDTH - 1:0]	  	DD_csr_op_o,
	output reg							decode_vaild_o,
	output reg [`PC_WIDTH - 1:0]    	DD_jmp_o,
	output reg							DD_op_jalr_o,
	output reg							DD_train_taken_o,
	output reg							DD_train_global_taken_o,
	output reg							DD_train_local_taken_o,
	output reg							DD_jal_o,
	output reg							DD_train_local_predict_o,
	output reg							DD_train_global_predict_o,
	output reg[`history_WIDTH - 1:0]	DD_train_global_history_o,
	output reg[`INSTR_WIDTH - 1:0]		DD_instr_o,
	output reg [`OP_WIDTH - 1:0]     	DD_epcode_o,
	output reg [`STORE_WIDTH - 1:0]  	DD_store_op_o,
	output reg [`LOAD_WIDTH - 1:0]   	DD_load_op_o,
	output reg [`BRANCH_WIDTH - 1:0] 	DD_branch_op_o,
	output reg [`ALU_WIDTH - 1:0]    	DD_ALU_op_o,
	output reg							DD_sel_reg_o,
	output reg [`PC_WIDTH - 1:0]		DD_nPC_o,
	output reg [`PC_WIDTH - 1:0]     	DD_PC_o,
	output reg                       	DD_need_dstE_o,
	output reg [4:0]                 	DD_dstE_o,
	output reg [`XLEN - 1:0]			DD_rs1_data_o,
	output reg [`XLEN - 1:0]			DD_rs2_data_o,
	output reg							DD_train_predict_o,
	output reg 							DD_train_vaild_o,
	output reg [`XLEN - 1:0] 			DD_imme_o,
	output reg 							DD_commit_o,
	output reg							DD_success_hit_o
);
	always @(posedge clk_i) begin
		if(rst | (~decode_control_i & execute_allow_in_i)) begin
			decode_vaild_o				<=0;
			DD_epcode_o 				<=0;
			DD_store_op_o				<=0;
			DD_load_op_o				<=0;
			DD_branch_op_o				<=0;
			DD_ALU_op_o					<=0;
			DD_sel_reg_o				<=0;
			DD_need_dstE_o				<=0;
			DD_dstE_o					<=0;
			DD_rs1_data_o				<=0;
			DD_rs2_data_o				<=0;
			DD_imme_o					<=0;
			DD_PC_o						<=`nop_PC;
			DD_nPC_o					<=`nop_nPC;
			DD_commit_o					<=`nop_commit;
			DD_instr_o					<=`nop_instr;
			DD_train_vaild_o			<= 0;
			DD_train_predict_o			<= 0;
			DD_train_global_history_o	<= 0;
			DD_train_global_predict_o	<= 0;
			DD_train_local_predict_o	<= 0;
			DD_success_hit_o			<= 0;
			DD_jal_o					<= 0;
			DD_train_taken_o			<= 0;
			DD_train_global_taken_o 	<= 0;
			DD_train_local_taken_o 		<= 0;
			DD_jmp_o					<= 0;
			DD_op_jalr_o				<= 0;
			DD_csr_op_o					<= 0;
			DD_need_CSR_o				<= 0;
			DD_csr_addr_o				<= 0;
			DD_csr_data_o				<= 0;
			DD_csr_mret_o				<= 0;
			DD_csr_ecall_o				<= 0;
		end
		else if(decode_ready_i & execute_allow_in_i) begin
			decode_vaild_o				<=decode_control_i;
			DD_epcode_o 				<=D_epcode_i;
			DD_store_op_o				<=D_store_op_i;
			DD_load_op_o				<=D_load_op_i;
			DD_branch_op_o				<=D_branch_op_i;
			DD_ALU_op_o					<=D_ALU_op_i;
			DD_sel_reg_o				<=D_sel_reg_i;
			DD_PC_o						<=D_PC_i;
			DD_need_dstE_o				<=D_need_dstE_i;
			DD_dstE_o					<=D_dstE_i;
			DD_rs1_data_o				<=D_rs1_data_i;
			DD_rs2_data_o				<=D_rs2_data_i;
			DD_imme_o					<=D_imme_i;
			DD_nPC_o					<=D_nPC_i;
			DD_commit_o					<=D_commit_i;
			DD_instr_o					<= D_instr_i;
			DD_train_vaild_o			<=D_train_vaild_i;
			DD_train_predict_o			<=D_train_predict_i;
			DD_train_global_history_o	<=D_train_global_history_i;
			DD_train_global_predict_o	<=D_train_global_predict_i;
			DD_train_local_predict_o	<=D_train_local_predict_i;
			DD_success_hit_o			<=D_success_hit_i;
			DD_jal_o					<=D_jal_i;
			DD_train_taken_o			<= D_train_taken_i;
			DD_train_global_taken_o 	<= D_train_global_taken_i;
			DD_train_local_taken_o 		<= D_train_local_taken_i;
			DD_jmp_o					<= D_jmp_i;
			DD_op_jalr_o				<= D_op_jalr_i;
			DD_csr_op_o					<= D_csr_op_i;
			DD_need_CSR_o				<= D_need_CSR_i;
			DD_csr_addr_o				<= D_csr_addr_i;
			DD_csr_data_o				<= D_csr_data_i;
			DD_csr_mret_o				<= D_csr_mret_i;
			DD_csr_ecall_o				<= D_csr_ecall_i
		end
		else if(~decode_ready_i & execute_allow_in_i) begin
			decode_vaild_o				<=0;
			DD_epcode_o 				<=0;
			DD_store_op_o				<=0;
			DD_load_op_o				<=0;
			DD_branch_op_o				<=0;
			DD_ALU_op_o					<=0;
			DD_sel_reg_o				<=0;			
			DD_need_dstE_o				<=0;
			DD_dstE_o					<=0;
			DD_rs1_data_o				<=0;
			DD_rs2_data_o				<=0;
			DD_imme_o					<=0;
			DD_PC_o						<=`nop_PC;
			DD_nPC_o					<=`nop_nPC;
			DD_commit_o					<=`nop_commit;
			DD_instr_o					<=`nop_instr;
			DD_train_vaild_o			<= 0;
			DD_train_predict_o			<= 0;
			DD_train_global_history_o	<= 0;
			DD_train_global_predict_o	<= 0;
			DD_train_local_predict_o	<= 0;
			DD_success_hit_o			<= 0;
			DD_jal_o					<= 0;
			DD_train_taken_o			<= 0;
			DD_train_global_taken_o 	<= 0;
			DD_train_local_taken_o 		<= 0;
			DD_jmp_o					<= 0;
			DD_op_jalr_o				<= 0;
			DD_csr_op_o					<= 0;
			DD_need_CSR_o				<= 0;
			DD_csr_addr_o				<= 0;
			DD_csr_data_o				<= 0;
			DD_csr_mret_o				<= 0;
			DD_csr_ecall_o				<= 0;
		end
	end
endmodule
