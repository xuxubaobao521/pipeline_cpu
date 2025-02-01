`include "define.v"
module execute_reg(
	input wire				rst,
	input wire				clk_i,
	input wire 				E_bubble_i,
	input wire				E_stall_i,
	input wire [`STORE_WIDTH - 1:0]  	DD_store_op_i,
	input wire [`LOAD_WIDTH - 1:0]   	DD_load_op_i,
	input wire				DD_sel_reg_i,
	input wire [`XLEN - 1:0]		DD_rs2_data_i,
	input wire                       	DD_need_dstE_i,
	input wire [4:0]                 	DD_dstE_i,
	input wire [`PC_WIDTH - 1:0]		DD_PC_i,
	input wire [`PC_WIDTH - 1:0]		E_nPC_i,
	input wire 				DD_commit_i,
	input wire [`XLEN - 1:0]		E_valE_i,
	input wire [`PC_WIDTH - 1:0]    	E_jmp_i,
	input wire				E_train_taken_i,
	input wire [`INSTR_WIDTH - 1:0]		DD_instr_i,
	input wire				DD_train_predict_i,
	input wire 				DD_train_vaild_i,
	input wire [`history_WIDTH - 1:0] 	DD_train_history_i,
	input wire				E_op_jalr_i,
	
	output reg [`INSTR_WIDTH - 1:0]		ED_instr_o,
	output reg [`STORE_WIDTH - 1:0]  	ED_store_op_o,
	output reg [`LOAD_WIDTH - 1:0]   	ED_load_op_o,
	output reg				ED_sel_reg_o,
	output reg [`XLEN - 1:0]		ED_rs2_data_o,
	output reg [`XLEN - 1:0]		ED_valE_o,
	output reg                       	ED_need_dstE_o,
	output reg [`PC_WIDTH - 1:0]    	ED_jmp_o,
	output reg [`PC_WIDTH - 1:0]		ED_PC_o,
	output reg [`PC_WIDTH - 1:0]		ED_nPC_o,
	output reg				ED_commit_o,
	output reg				ED_train_predict_o,
	output reg 				ED_train_vaild_o,
	output reg				ED_train_taken_o,
	output reg [`history_WIDTH - 1:0] 	ED_train_history_o,
	output reg				ED_op_jalr_o,
	output reg [4:0]                 	ED_dstE_o
);
	always @(posedge clk_i) begin
		if(E_bubble_i | rst) begin
			ED_store_op_o 	<= 0;
			ED_load_op_o 	<= 0;
			ED_sel_reg_o	<= 0;
			ED_rs2_data_o	<= 0;
			ED_valE_o	<= 0;
			ED_need_dstE_o 	<= 0;
			ED_dstE_o	<= 0;
			ED_jmp_o	<= 0;
			ED_PC_o		<= `nop_PC;
			ED_nPC_o	<= `nop_nPC;
			ED_commit_o	<= `nop_commit;
			ED_instr_o	<= `nop_instr;
			ED_op_jalr_o		<= 0;
			
			ED_train_vaild_o	<= 0;
			ED_train_predict_o	<= 0;
			ED_train_history_o	<= 0;
			ED_train_taken_o	<= 0;
		end
		else begin
			ED_store_op_o 	<= DD_store_op_i;
			ED_load_op_o 	<= DD_load_op_i;
			ED_sel_reg_o	<= DD_sel_reg_i;
			ED_rs2_data_o	<= DD_rs2_data_i;
			ED_valE_o	<= E_valE_i;
			ED_need_dstE_o	<= DD_need_dstE_i;
			ED_dstE_o	<= DD_dstE_i;
			ED_jmp_o	<= E_jmp_i;
			ED_PC_o		<= DD_PC_i;
			ED_nPC_o	<= E_nPC_i;
			ED_commit_o	<= DD_commit_i;
			ED_instr_o	<= DD_instr_i;
			ED_op_jalr_o		<=E_op_jalr_i;
			
			ED_train_vaild_o	<=DD_train_vaild_i;
			ED_train_predict_o	<=DD_train_predict_i;
			ED_train_history_o	<= DD_train_history_i;
			ED_train_taken_o	<= E_train_taken_i;
		end
	end
endmodule
