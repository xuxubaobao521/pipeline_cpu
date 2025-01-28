`include "define.v"
module PC_reg(
	//input
	input wire rst,
	input wire clk_i,
	input wire PC_bubble_i,
	input wire PC_stall_i,
	input wire [`PC_WIDTH - 1 : 0] nPC_i,
	//output
	output reg [`PC_WIDTH - 1 : 0] F_PC_o
);
	always @(posedge clk_i) begin
		if(PC_bubble_i | rst) begin
			F_PC_o <= 32'h80000000;
		end
		else if(~PC_stall_i) begin
			F_PC_o <= nPC_i;
		end
	end
endmodule
