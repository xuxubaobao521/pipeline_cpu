`include "define.v"
module fwd(
	input wire[4:0]				D_rs1_i,
	input wire[4:0] 			D_rs2_i,
	
	input wire[`XLEN - 1:0]		D_rs1_data_i,
	input wire[`XLEN - 1:0] 	D_rs2_data_i,

	input wire					DD_need_dstE_i,
	input wire[4:0] 			DD_dstE_i,
	input wire[`XLEN - 1:0] 	E_valE_i,

	input wire 					ED_need_dstE_i,
	input wire[4:0] 			ED_dstE_i,
	input wire					ED_sel_reg_i,
	input wire[`XLEN - 1:0] 	ED_valE_i,
	input wire[`XLEN - 1:0] 	M_valM_i,
	
	input wire					MD_need_dstE_i,
	input wire[4:0]				MD_dstE_i,
	input wire[`XLEN - 1:0]		W_data_i,

	output wire [`XLEN - 1:0] 	D_fwdA_o,
	output wire [`XLEN - 1:0] 	D_fwdB_o
);
	assign D_fwdA_o = 	(D_rs1_i == 5'b0) ? {`XLEN{1'b0}} :
						(D_rs1_i == DD_dstE_i & DD_need_dstE_i) ? E_valE_i :
						(D_rs1_i == ED_dstE_i & ED_sel_reg_i & ED_need_dstE_i) ? ED_valE_i :
						(D_rs1_i == ED_dstE_i & ED_need_dstE_i) ? M_valM_i :
						(D_rs1_i == MD_dstE_i & MD_need_dstE_i) ? W_data_i : D_rs1_data_i;

	assign D_fwdB_o = 	(D_rs2_i == 5'b0) ? {`XLEN{1'b0}} :
						(D_rs2_i == DD_dstE_i & DD_need_dstE_i) ? E_valE_i :
						(D_rs2_i == ED_dstE_i & ED_sel_reg_i & ED_need_dstE_i) ? ED_valE_i :
						(D_rs2_i == ED_dstE_i & ED_need_dstE_i) ? M_valM_i :
						(D_rs2_i == MD_dstE_i & MD_need_dstE_i) ? W_data_i : D_rs2_data_i;
endmodule
