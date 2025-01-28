`include "define.v"
module write_back(
	//input
	input wire	[`INSTR_WIDTH - 1:0]MD_instr_i,
	input wire               		MD_sel_reg_i,
	input wire	[`XLEN - 1:0]  		MD_valE_i,
	input wire 	[`XLEN - 1:0] 		MD_valM_i,
	//output
	output wire	[`XLEN - 1:0] 		W_data_o
);
	import "DPI-C" function void dpi_ebreak		(input int pc);
	always @(*) begin
	if(MD_instr_i == 32'h00100073) begin
		dpi_ebreak(0);
	end
end
	assign W_data_o = (MD_sel_reg_i) ? MD_valE_i : MD_valM_i;
endmodule

