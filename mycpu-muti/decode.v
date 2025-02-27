`include "define.v"
module decode(
	//input
	input wire					rst,
	input wire                	clk_i,
	input wire [4:0]			D_rs1_i,
	input wire [4:0]			D_rs2_i,
	input wire                	MD_need_dstE_i,
	input wire					memory_vaild_i,
	input wire [4:0]          	MD_dstE_i,
	input wire [`XLEN - 1:0]  	data_i,
	//output
	output wire [`XLEN - 1:0] 	D_rs1_data_o,
	output wire [`XLEN - 1:0] 	D_rs2_data_o
);
	reg[`XLEN - 1:0] reg_file[`XLEN - 1:0];
	import "DPI-C" function void dpi_read_regfile(input logic [31 : 0] a []);
	initial begin
		dpi_read_regfile(reg_file);
	end
	always @(posedge clk_i) begin
		if(rst) 
			reg_file[0] <= 0;
		else if(MD_need_dstE_i & (MD_dstE_i != 0) & memory_vaild_i) 
			reg_file[MD_dstE_i] <= data_i;
	end
	assign D_rs1_data_o = reg_file[D_rs1_i];
	assign D_rs2_data_o = reg_file[D_rs2_i];
endmodule