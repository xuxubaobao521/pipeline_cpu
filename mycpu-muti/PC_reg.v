`include "define.v"
module PC_reg(
	//input
	input wire 			rst,
	input wire 			clk_i,
	input wire [`PC_WIDTH - 1 : 0] 	nPC_i,
	input wire			fetch_allow_in_i,
	input wire 			PC_ready_i,
	//output
	output reg 			PC_vaild_o,
	output reg [`PC_WIDTH - 1 : 0] 	F_PC_o
);
	always @(posedge clk_i) begin
		if(rst) begin
			F_PC_o <= 32'h80000000;
			PC_vaild_o <= 1'b1;
		end
		else if(fetch_allow_in_i & PC_ready_i) begin
			F_PC_o <= nPC_i;
		end
	end
endmodule
