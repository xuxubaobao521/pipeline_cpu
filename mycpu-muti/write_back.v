`include "define.v"
module write_back(
	//input
	input wire[`INSTR_WIDTH - 1:0] M_instr_i,
	input wire               F_sel_reg_i,
	input wire[`XLEN - 1:0]  E_data_i,
	input wire [`XLEN - 1:0] M_data_i,
	//output
	output wire[`XLEN - 1:0] W_data_o
);
	import "DPI-C" function void dpi_ebreak		(input int pc);
	always @(*) begin
	if(M_instr_i == 32'h00100073) begin
		dpi_ebreak(0);
	end
end
	assign W_data_o = (F_sel_reg_i) ? E_data_i : M_data_i;
endmodule

